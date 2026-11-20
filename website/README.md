# DetechX marketing website

A standalone React + Vite website. The existing Flutter customer app, map lab and dispatch demo remain separate and unchanged. This site has Home, Services, How it works, Partners, Interactive demo, Privacy and a fallback screen. The browser-only demo does not create appointments or initiate payment.

## Run the site

Use Node.js 22.12+.

```sh
cd website
npm ci
npm run dev
# Production bundle:
npm run build
npm run preview
```

## Deploy to Vercel

Import the DetechX Git repository. Set **Root Directory** to `website`, **Framework Preset** to **Vite**, and select Node.js **22.x** or a compatible newer supported version. The build command is `npm run build`, the output directory is `dist`, and no environment variables are required. Keep `vercel.json` so refreshing routes like `/services` or `/demo` works. Validate on a preview deployment before promoting to production. No deployment was created by this change.

## Learn from this build

- `src/Aura.jsx`: minimal WebGL full-screen triangle with a GLSL fragment shader. It is decorative, capped to ~30 fps, and pauses offscreen, in background tabs, or for reduced motion. The image and text still work without it.
- `src/main.jsx`: route-scoped GSAP entrances with cleanup and a CSS fallback. Route navigation uses React Router. Don’t add Barba on top of it just for transitions—both would handle navigation.
- [Motion repo shortlist and AI-agent workflow](../docs/web-motion-references.md).

Photography assets in `public/` were generated for this prototype; the people pictured are illustrative, not claims about available technicians. Inter is bundled with its license.
