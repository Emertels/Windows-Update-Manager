# Agent instructions

## Purpose and project identity

- Preserve the purpose, workflow, and visual choices Emerson refined manually. Before redesigning an interface, compare it with the existing version and change only what is needed to fix a requested issue.
- Keep the project version at `1.0.0` until an explicit version change. Update both language changelogs when behavior, UI, requirements, or documentation change.
- Preserve the file names and formats chosen for the project. Projects selected as Batch must remain a single `.bat` file, without a parallel `.ps1` copy.

## Languages, terminal, and appearance

- Every interface must offer exactly these ten languages and detect Windows UI culture automatically: Brazilian Portuguese (`pt-BR`), English (`en`), Spanish (`es`), French (`fr`), German (`de`), Italian (`it`), Japanese (`ja`), Korean (`ko`), Simplified Chinese (`zh-CN`), and Russian (`ru`). Fall back to PT-BR.
- Translate user-facing messages, prompts, states, errors, and usage instructions. Keep commands, parameters, registry identifiers, technical paths, and literal operating-system output untranslated.
- Use correct Brazilian Portuguese accents and cedilla in PT-BR text, and native spelling and punctuation in other languages. Do not add `chcp 65001 >nul` to `.bat` files or use ANSI bold sequences. Preserve interface colors and follow the project-approved header layout.
- Session headers must show version, start date, start time, and detected language. Avoid redesigning screens the author has already approved.

## Safety and compatibility

- Do not perform destructive actions during review or validation. Explain network, registry, cleanup, or update effects and preserve appropriate confirmations.
- Validate input and check exit codes. Never report success when an operation fails or cannot be confirmed.
- Maintain documented compatibility and requirements. Do not add unnecessary dependencies or claim support that is not implemented.
- Do not include personal data, credentials, logs, temporary files, or unrelated generated files.

## Documentation and releases

- Keep `README.md` as the primary PT-BR documentation and `README-EN.md` as its separate English counterpart. Both should explain purpose, requirements, usage, limitations, and all ten languages without unnecessary repetition.
- Also update `AGENTS-PT-BR.md`, `AGENTS-EN.md`, both changelogs, and the project description when needed.
- Keep the MIT license in the repository.
- A release ZIP must contain only files needed to use the project; exclude README, changelog, AGENTS, license, and assets.
