import { useEffect, useRef } from "react";

// Optional, low-resolution WebGL accent. The poster and all text are DOM layers.
export default function Aura() {
  const ref = useRef(null);
  useEffect(() => {
    const canvas = ref.current,
      motion = matchMedia("(prefers-reduced-motion: reduce)");
    if (motion.matches) return;
    const gl = canvas.getContext("webgl", {
      alpha: true,
      antialias: false,
      premultipliedAlpha: false,
    });
    if (!gl) return;
    const shader = (type, source) => {
      const s = gl.createShader(type);
      gl.shaderSource(s, source);
      gl.compileShader(s);
      return s;
    };
    const vertex = shader(
      gl.VERTEX_SHADER,
      "attribute vec2 position; void main(){gl_Position=vec4(position,0.,1.);}",
    );
    const fragment = shader(
      gl.FRAGMENT_SHADER,
      `precision mediump float; uniform vec2 size; uniform float time;
   void main(){vec2 p=gl_FragCoord.xy/size; vec2 c=vec2(.80+.06*sin(time*.28),.34+.08*cos(time*.35));
   float d=length((p-c)*vec2(1.24,1.)); float glow=exp(-8.*d*d)*(1.-smoothstep(.16,.72,d));
   float wave=.8+.2*sin(20.*d-time*.85); gl_FragColor=vec4(.99,.34,.12,glow*wave*.19);}`,
    );
    const program = gl.createProgram();
    gl.attachShader(program, vertex);
    gl.attachShader(program, fragment);
    gl.linkProgram(program);
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
      gl.deleteProgram(program);
      gl.deleteShader(vertex);
      gl.deleteShader(fragment);
      return;
    }
    gl.useProgram(program);
    const buffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    gl.bufferData(
      gl.ARRAY_BUFFER,
      new Float32Array([-1, -1, 3, -1, -1, 3]),
      gl.STATIC_DRAW,
    );
    const pos = gl.getAttribLocation(program, "position");
    gl.enableVertexAttribArray(pos);
    gl.vertexAttribPointer(pos, 2, gl.FLOAT, false, 0, 0);
    const size = gl.getUniformLocation(program, "size"),
      time = gl.getUniformLocation(program, "time");
    let frame = 0,
      visible = false,
      last = -1000;
    function draw(now) {
      if (!visible || document.hidden || motion.matches) {
        frame = 0;
        return;
      }
      frame = requestAnimationFrame(draw);
      if (now - last < 33) return;
      last = now;
      const w = Math.max(
          1,
          Math.min(530, Math.round(canvas.clientWidth * 0.65)),
        ),
        h = Math.max(1, Math.round(canvas.clientHeight * 0.65));
      if (canvas.width !== w || canvas.height !== h) {
        canvas.width = w;
        canvas.height = h;
        gl.viewport(0, 0, w, h);
      }
      gl.uniform2f(size, w, h);
      gl.uniform1f(time, now * 0.001);
      gl.drawArrays(gl.TRIANGLES, 0, 3);
    }
    const sync = () => {
      if (frame) {
        cancelAnimationFrame(frame);
        frame = 0;
      }
      canvas.style.visibility = motion.matches ? "hidden" : "";
      if (visible && !document.hidden && !motion.matches)
        frame = requestAnimationFrame(draw);
    };
    const observer = new IntersectionObserver(([entry]) => {
      visible = entry.isIntersecting;
      sync();
    });
    observer.observe(canvas);
    motion.addEventListener("change", sync);
    document.addEventListener("visibilitychange", sync);
    return () => {
      cancelAnimationFrame(frame);
      observer.disconnect();
      motion.removeEventListener("change", sync);
      document.removeEventListener("visibilitychange", sync);
      gl.deleteBuffer(buffer);
      gl.deleteProgram(program);
      gl.deleteShader(vertex);
      gl.deleteShader(fragment);
    };
  }, []);
  return <canvas className="aura" ref={ref} aria-hidden="true" />;
}
