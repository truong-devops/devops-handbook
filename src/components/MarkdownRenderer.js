'use client';

import { useState } from 'react';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';

function CodeBlock({ children }) {
  const codeElement = Array.isArray(children) ? children[0] : children;
  const raw = codeElement?.props?.children ?? '';
  const text = Array.isArray(raw) ? raw.join('') : String(raw);
  const [copied, setCopied] = useState(false);

  async function copy() {
    await navigator.clipboard.writeText(text.replace(/\n$/, ''));
    setCopied(true);
    setTimeout(() => setCopied(false), 1200);
  }

  return (
    <div className="code-shell">
      <button type="button" className="copy-button" onClick={copy}>{copied ? 'Copied ✓' : 'Copy'}</button>
      <pre>{children}</pre>
    </div>
  );
}

export default function MarkdownRenderer({ content }) {
  return (
    <article className="markdown-body">
      <ReactMarkdown
        remarkPlugins={[remarkGfm]}
        components={{ pre: CodeBlock }}
      >
        {content}
      </ReactMarkdown>
    </article>
  );
}
