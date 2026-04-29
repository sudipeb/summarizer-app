# GitHub MCP Setup

This workspace is configured with a GitHub MCP server in [`.vscode/mcp.json`](../.vscode/mcp.json).

## What was created

- A workspace-scoped MCP configuration file.
- A `github` server definition that uses:
  - `npx`
  - `@modelcontextprotocol/server-github`
- A secure token prompt named `github-personal-access-token` so the GitHub token is not hardcoded.

## How to make it active on this device

1. Open this workspace in VS Code.
2. Make sure the **GitHub Copilot Chat** extension is installed.
3. Open the Command Palette.
4. Run `MCP: List Servers`.
5. Select `github`.
6. Start the server.
7. When VS Code asks for the token, paste your GitHub personal access token.
8. Accept the MCP trust prompt.
9. If the server does not appear, run `Developer: Reload Window` and check `MCP: List Servers` again.

## How to use it on another device

1. Copy or clone this repository on the other device.
2. Make sure the `.vscode/mcp.json` file is included in the workspace.
3. Install the **GitHub Copilot Chat** extension on that device.
4. Open the repository in VS Code.
5. Run `MCP: List Servers`.
6. Start the `github` server.
7. Enter a GitHub personal access token when prompted on that device.
8. Accept the trust prompt.

## Notes

- The token prompt is stored per VS Code profile/device, so each machine may ask for the token separately.
- If you change the MCP configuration, restart or reload VS Code so the tools are rediscovered.
- If the server was started before and its tools do not show up, run `MCP: Reset Cached Tools` and then try `MCP: List Servers` again.
