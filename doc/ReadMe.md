# Makes Documentation

This directory contains detailed documentation for Makes modules that require more explanation than inline comments can provide.

## Why This Directory Exists

Most `.mk` files in Makes are self-documenting through their structure and inline comments. However, some modules provide more complex functionality that benefits from dedicated documentation:

- **Complex workflows** - Modules with multiple configuration options and use cases
- **Template systems** - Modules that process or generate files
- **Integration guides** - Modules that interact with external tools or standards
- **Best practices** - Modules where usage patterns need explanation

## Documentation Files

Each documented module has its own file:

- **[agents.md](agents.md)** - AI coding agent configuration file generator

## Documentation Standards

When creating documentation for a Makes module:

1. **Start with a clear overview** - What does this module do?
2. **Explain the workflow** - How does it work?
3. **Show configuration options** - What can users customize?
4. **Provide examples** - Real-world usage scenarios
5. **Include troubleshooting** - Common issues and solutions

## When to Add Documentation

Create a `doc/<module>.md` file when:

- The module has more than 3 configuration variables
- The module generates or processes files
- The module has conditional behavior (e.g., OS-specific)
- Users need to create supporting files (templates, configs, etc.)
- The module integrates with external standards or tools

Simple tool installers (like `go.mk`, `rust.mk`) typically don't need dedicated documentation as their usage is straightforward.
