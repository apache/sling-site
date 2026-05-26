title=MCP Server
type=page
status=published
tags=mcp,ai,tooling,bundles
~~~~~~

Apache Sling can expose a [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) server from a running Sling instance. This allows MCP-aware clients to inspect and interact with Sling through HTTP, using tools and prompts contributed by Sling bundles.

The MCP endpoint is exposed at `/bin/mcp`.

## Overview

The Sling MCP server is intended for development and diagnostics against a running Sling instance.

This page documents a setup based on the `apache/sling` Docker image. Pending a release of version 15, a snapshot version is ued.

## Starting Sling Starter With MCP Features

Docker is required for the setup described here.

Until Sling Starter 15 is released, use the `apache/sling:snapshot` Docker image.

Launch the Sling Starter container image and add both MCP feature models using `--extra-features`.

    docker run --rm -p 8080:8080 \
      apache/sling:snapshot oak_tar \
      --extra-features \
        mvn:org.apache.sling/org.apache.sling.mcp-server/0.1.4/slingosgifeature/main \
        mvn:org.apache.sling/org.apache.sling.mcp-server-contributions/0.1.0/slingosgifeature/main

## Configuring MCP clients

Configuration depends on the particular MCP client you are using. The key points are:

- the MCP server URL is `http://localhost:8080/bin/mcp`
- HTTP Basic authentication with admin credentials is required

The MCP servlet allows access only for admin users. This prevents unauthorized access to potentially sensitive information and operations exposed through the MCP server.

Read on for instructions for specific clients.

### OpenCode

OpenCode can connect to the Sling MCP server using a remote MCP definition.

Example `opencode.json`:

    {
      "$schema": "https://opencode.ai/config.json",
      "mcp": {
        "sling": {
          "type": "remote",
          "url": "http://localhost:8080/bin/mcp",
          "headers": {
            "Authorization": "Basic YWRtaW46YWRtaW4="
          }
        }
      }
    }

### Claude CLI

Claude Code can connect to the Sling MCP server as a remote HTTP MCP server.

Example command:

    claude mcp add --transport http \
      sling http://localhost:8080/bin/mcp \
      --header "Authorization: Basic YWRtaW46YWRtaW4="

## Default Contributions

The base `org.apache.sling.mcp-server` bundle provides the HTTP MCP endpoint and prompt discovery from the Sling repository.

The `org.apache.sling.mcp-server-contributions` bundle adds the default Sling-specific tools and prompts.

### MCP Tools

The following tools are available by default:

* `logs`
  Returns recent Sling logs with optional filtering by regex, log level and maximum number of entries.
* `recent-requests`
  Returns recent Sling requests, including method, path, user id and request progress log output.
* `diagnose-osgi-bundle`
  Diagnoses inactive or problematic OSGi bundles and Declarative Services components.

### MCP Prompts

The following prompts are available by default:

* `troubleshoot`
  A troubleshooting guide for common Sling and MCP server issues.
* `new-sling-servlet`
  A prompt template for creating a new Sling servlet based on a resource type.

Prompts are discovered from repository content under `/libs/sling/mcp/prompts`.

## Verifying The Setup

Once Sling is running and your MCP client is configured:

* connect the client to `http://localhost:8080/bin/mcp`
* authenticate as an admin user
* confirm that the default tools are visible: `logs`, `recent-requests`, `diagnose-osgi-bundle`
* confirm that the default prompts are visible: `troubleshoot`, `new-sling-servlet`

If the MCP endpoint is not reachable, verify that both MCP features were added successfully and that the client sends valid Basic authentication credentials.

## Sample Prompts

Once the server is connected, prompts like the following are good starting points:

* `Analyse errors from my Sling instance`
* `Where was most of the time spent in the request to /starter.html?`
* `Why did bundle org.acme.foo fail to start?`

## Extending The Server

The Sling MCP server is extensible in two main ways:

* register additional `McpServerContribution` services to expose new tools, prompts, resources or completions
* install prompt content below `/libs/sling/mcp/prompts` so that it is discovered automatically

This makes it possible to keep the server itself minimal while packaging Sling-specific or project-specific MCP capabilities in separate bundles.
