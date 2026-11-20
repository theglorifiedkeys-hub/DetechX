# Premium web motion: repositories worth studying

| Want to learn | Repository | What to study |
| --- | --- | --- |
| WebGL fundamentals | [gfxfundamentals/webgl-fundamentals](https://github.com/gfxfundamentals/webgl-fundamentals) | Buffers, shaders and rendering a first effect without a scene library |
| GLSL fragment shaders | [patriciogonzalezvivo/thebookofshaders](https://github.com/patriciogonzalezvivo/thebookofshaders) | Coordinates, color, shapes, smoothstep and procedural noise |
| Small WebGL effects | [oframe/ogl](https://github.com/oframe/ogl) | Minimal scenes, textures and effects in the examples |
| 3D scenes | [mrdoob/three.js](https://github.com/mrdoob/three.js) | Official examples of materials, camera controls and postprocessing |
| WebGL in React | [pmndrs/react-three-fiber](https://github.com/pmndrs/react-three-fiber) and [pmndrs/drei](https://github.com/pmndrs/drei) | Declarative scenes and reusable helpers |
| Shader-driven visuals | [codrops/WebGLBlobs](https://github.com/codrops/WebGLBlobs) | How vertex deformation and fragment color combine in an effect |
| Scroll choreography | [codrops/ScrollBasedLayoutAnimations](https://github.com/codrops/ScrollBasedLayoutAnimations) and [GreenSock/GSAP](https://github.com/greensock/GSAP) | ScrollTrigger and Flip for one deliberate section, not every block |
| Page transitions | [barbajs/barba](https://github.com/barbajs/barba) | Lifecycle hooks for server-rendered pages. Use router-native transitions in a React SPA instead of two competing navigators. |
| UI animation | [juliangarnier/anime](https://github.com/juliangarnier/anime) | Staggered DOM/SVG timelines and brief interactions |
| Numeric interpolation | [tweenjs/tween.js](https://github.com/tweenjs/tween.js) | Tweening JS properties in an existing render loop, e.g. a camera or material uniform |

## An AI-agent brief that keeps the work focused

> Build one responsive editorial hero, then one interactive demo. Start with HTML and CSS so the text and navigation work before animation. Add one decorative WebGL effect with a poster fallback, and one GSAP entrance timeline with route cleanup. Test 360px and 1440px, keyboard navigation, reduced motion and unavailable WebGL. Show the build command, screenshots, and what was verified.

Ask the agent to study an example and explain what it will adapt before generating code. Check the repo license and asset provenance separately before copying a demo into a commercial site. Don’t add GSAP, Anime.js and tween.js for the same animation; choose one timeline engine and add a shader only when it improves the design.
