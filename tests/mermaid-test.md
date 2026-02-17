# Mermaid Test

This file tests if mermaid diagrams still work after our changes.

## Simple Flowchart

```mermaid
graph TD
    A[Start] --> B{Is it working?}
    B -->|Yes| C[Great!]
    B -->|No| D[Debug]
    D --> B
    C --> E[End]
```

## Sequence Diagram

```mermaid
sequenceDiagram
    participant Browser
    participant Server
    participant Neovim
    
    Browser->>Server: Request markdown file
    Server->>Neovim: Read file content
    Neovim-->>Server: Return content
    Server-->>Browser: Send HTML
    Browser->>Browser: Render with KaTeX
```

## Test with Math

Here's some inline math: $E = mc^2$

And a block equation:
$$
\begin{cases}
x + y = 10 \\
x - y = 2
\end{cases}
$$

Both should work together!
