#Theosis C09 v2: every claude session gets its own memory box inside agents.slice.
#OOMPolicy=continue means a runaway child (a build, a test) dies alone and the session lives.
#No exec here on purpose: exec moved claude out of its box on WSL (audit 2026-09-30).
claude() {
  systemd-run --user --scope --quiet --slice=agents.slice \
    -p MemoryHigh=10G -p MemoryMax=12G -p MemorySwapMax=4G -p OOMPolicy=continue \
    -- env CLAUDE_CODE_TOOL_MEMORY_LIMIT=6G claude "$@"
}
