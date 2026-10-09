import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const fmt = (n: number) =>
	n < 1000 ? `${n}` : n < 1e6 ? `${(n / 1000).toFixed(n < 1e4 ? 1 : 0)}k` : `${(n / 1e6).toFixed(1)}M`;

const BAR_WIDTH = 8;
const DEFAULT_BRANCHES = new Set(["main", "master", "develop", "dev", "trunk"]);

export default function (pi: ExtensionAPI) {
	let dirty = false;
	let refresh: () => void = () => {};

	// Refresh the dirty marker when the agent may have changed files
	pi.on("tool_result", async () => refresh());
	pi.on("agent_end", async () => refresh());

	pi.on("session_start", async (_event, ctx) => {
		if (!ctx.hasUI) return;

		ctx.ui.setFooter((tui, theme, footerData) => {
			let inflight = false;
			let last = 0;
			refresh = () => {
				if (inflight || Date.now() - last < 2000) return;
				inflight = true;
				last = Date.now();
				pi.exec("git", ["status", "--porcelain"], { cwd: ctx.cwd, timeout: 5000 })
					.then((r) => {
						const next = r.code === 0 && r.stdout.trim().length > 0;
						if (next !== dirty) {
							dirty = next;
							tui.requestRender();
						}
					})
					.catch(() => {})
					.finally(() => {
						inflight = false;
					});
			};
			refresh();
			const unsub = footerData.onBranchChange(() => {
				last = 0;
				refresh();
				tui.requestRender();
			});
			const sep = theme.fg("dim", " │ ");

			const branchLabel = (branch: string) => {
				const mark = dirty ? theme.fg("warning", "*") : "";
				if (DEFAULT_BRANCHES.has(branch)) return theme.fg("muted", ` ${branch}`) + mark;
				return theme.fg("mdLink", ` ${branch}`) + mark;
			};

			return {
				dispose: unsub,
				invalidate() {},
				render(width: number): string[] {
					// Session totals + latest cache hit rate (same sources as pi's built-in footer)
					let input = 0, output = 0, cost = 0, lastHit: number | undefined;
					const add = (u: any) => {
						if (!u) return;
						input += u.input ?? 0;
						output += u.output ?? 0;
						cost += u.cost?.total ?? 0;
					};
					for (const e of ctx.sessionManager.getEntries() as any[]) {
						if (e.type === "usage") add(e.usage);
						else if (e.type === "message" && e.message.role === "assistant") {
							const u = e.message.usage;
							add(u);
							const prompt = u.input + u.cacheRead + u.cacheWrite;
							lastHit = prompt > 0 ? (u.cacheRead / prompt) * 100 : undefined;
						} else if (e.type === "message" && e.message.role === "toolResult") add(e.message.usage);
						else if (e.type === "branch_summary" || e.type === "compaction") add(e.usage);
					}

					// Location: project, branch, session name
					const project = ctx.cwd.split("/").filter(Boolean).pop() ?? "/";
					const branch = footerData.getGitBranch();
					const session = ctx.sessionManager.getSessionName?.();
					let where = theme.fg("accent", project);
					if (branch) where += " " + branchLabel(branch);
					if (session) where += theme.fg("dim", " • ") + theme.fg("muted", session);

					// Stats: tokens, cache, cost, context
					const parts: string[] = [];
					parts.push(theme.fg("muted", "↑") + theme.fg("text", fmt(input)) + " " + theme.fg("muted", "↓") + theme.fg("text", fmt(output)));
					if (lastHit !== undefined) {
						const c = lastHit >= 80 ? "success" : lastHit >= 50 ? "warning" : "error";
						parts.push(theme.fg("muted", "cache ") + theme.fg(c, `${lastHit.toFixed(0)}%`));
					}
					parts.push(theme.fg("warning", `$${cost.toFixed(3)}`));

					const usage = ctx.getContextUsage();
					if (usage) {
						const pct = usage.percent;
						const c = pct === null ? "muted" : pct > 85 ? "error" : pct > 60 ? "warning" : "success";
						const filled = Math.round(((pct ?? 0) / 100) * BAR_WIDTH);
						const bar = theme.fg(c, "▰".repeat(filled)) + theme.fg("dim", "▱".repeat(BAR_WIDTH - filled));
						const label = pct === null ? "?" : `${pct.toFixed(1)}%`;
						let ctxStr = `${bar} ${theme.fg(c, label)}${theme.fg("dim", "/" + fmt(usage.contextWindow))}`;
						if (pct !== null && pct > 85) ctxStr += " " + theme.fg("error", "⚠ compact soon");
						parts.push(ctxStr);
					}
					const stats = parts.join(sep);

					// Right side: extension statuses + model + thinking level
					const statuses = [...footerData.getExtensionStatuses().values()].join(" ");
					const model = ctx.model?.id ?? "no-model";
					const level = pi.getThinkingLevel();
					let modelStr = theme.fg("accent", model);
					if (level && level !== "off") modelStr += theme.fg("dim", " • ") + theme.fg("warning", level);

					const line = (l: string, r: string) => {
						const gap = Math.max(1, width - visibleWidth(l) - visibleWidth(r));
						return truncateToWidth(l + " ".repeat(gap) + r, width);
					};

					// One line when it fits, two otherwise
					const oneLeft = where + sep + stats;
					const oneRight = statuses ? theme.fg("muted", statuses) + sep + modelStr : modelStr;
					if (visibleWidth(oneLeft) + visibleWidth(oneRight) + 2 <= width) return [line(oneLeft, oneRight)];
					return [line(where, statuses ? theme.fg("muted", statuses) : ""), line(stats, modelStr)];
				},
			};
		});
	});
}
