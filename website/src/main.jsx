import React, { useEffect, useLayoutEffect, useRef, useState } from "react";
import { createRoot } from "react-dom/client";
import {
  BrowserRouter,
  Link,
  NavLink,
  Route,
  Routes,
  useLocation,
  useSearchParams,
} from "react-router-dom";
import gsap from "gsap";
import {
  ArrowDown,
  ArrowRight,
  ArrowUpRight,
  Check,
  ChevronRight,
  Clock3,
  Droplets,
  MapPin,
  Menu,
  Radio,
  ShieldCheck,
  Snowflake,
  Sparkles,
  Wrench,
  X,
  Zap,
} from "lucide-react";
import Aura from "./Aura";
import "./style.css";

const services = [
  {
    id: "cooling",
    icon: Snowflake,
    name: "AC & Cooling",
    summary:
      "Diagnostics, servicing, and repair for split units that aren’t keeping up.",
    issue: "My AC is running but not cooling.",
    range: [45000, 80000],
  },
  {
    id: "plumbing",
    icon: Droplets,
    name: "Plumbing",
    summary: "Find the cause of leaks, slow drains, and water pressure issues.",
    issue: "My kitchen sink is leaking.",
    range: [40000, 75000],
  },
  {
    id: "electrical",
    icon: Zap,
    name: "Electrical",
    summary: "Get help with faulty outlets, lighting, and power interruptions.",
    issue: "An outlet stopped working.",
    range: [50000, 90000],
  },
  {
    id: "maintenance",
    icon: Wrench,
    name: "Home Maintenance",
    summary: "Tackle small repairs and keep your home working as it should.",
    issue: "I need help with a home repair.",
    range: [40000, 70000],
  },
];
const areas = [
  "Mikocheni",
  "Sinza",
  "Kinondoni",
  "Mbezi Beach",
  "Upanga",
  "Kigamboni",
  "Masaki",
];
const money = (value) => new Intl.NumberFormat("en-TZ").format(value);
const nav = [
  ["Services", "/services"],
  ["How it works", "/how-it-works"],
  ["For partners", "/partners"],
];
const stages = [
  "Fundi yuko njiani",
  "Fundi amefika",
  "Kazi inaendelea",
  "Kazi imekamilika",
];
const steps = [
  [
    "Describe the issue",
    "Tell us what’s happening in your own words. The assistant asks a short follow-up when it helps.",
  ],
  [
    "Review the estimate",
    "Get a starting range in Tanzanian shillings. A technician checks the problem before confirming the final price.",
  ],
  [
    "Follow the visit",
    "See when your fundi is on the way, has arrived, and has completed the job.",
  ],
];
function Brand() {
  return (
    <Link className="brand" to="/" aria-label="DetechX home">
      <img src="/mark.svg" alt="" width="33" height="33" />
      Detech<span>X</span>
    </Link>
  );
}
function Button({ to, children, secondary = false }) {
  return (
    <Link className={`button ${secondary ? "secondary" : ""}`} to={to}>
      {children}
    </Link>
  );
}
function Header() {
  const [open, set] = useState(false);
  const { pathname } = useLocation();
  useEffect(() => {
    set(false);
  }, [pathname]);
  return (
    <header className="header wrap">
      <Brand />
      <button
        className="menu-toggle"
        type="button"
        onClick={() => set(!open)}
        aria-expanded={open}
        aria-controls="site-nav"
        aria-label={open ? "Close menu" : "Open menu"}
      >
        {open ? <X /> : <Menu />}
      </button>
      <nav
        id="site-nav"
        className={open ? "nav open" : "nav"}
        aria-label="Main navigation"
      >
        {nav.map(([name, path]) => (
          <NavLink key={path} to={path}>
            {name}
          </NavLink>
        ))}
      </nav>
      <Button to="/demo" secondary>
        Try the demo <ArrowUpRight size={15} />
      </Button>
    </header>
  );
}
function Footer() {
  return (
    <footer className="footer wrap">
      <Brand />
      <p>
        Home services, made clearer.
        <br />
        Dar es Salaam, Tanzania.
      </p>
      <nav aria-label="Footer navigation">
        {[...nav, ["Interactive demo", "/demo"], ["Privacy", "/privacy"]].map(
          ([label, path]) => (
            <Link key={path} to={path}>
              {label}
            </Link>
          ),
        )}
      </nav>
      <small>© {new Date().getFullYear()} DetechX</small>
    </footer>
  );
}
function Eyebrow({ children }) {
  return (
    <div className="eyebrow">
      <i />
      {children}
    </div>
  );
}
function ServicesGrid() {
  return (
    <div className="service-grid">
      {services.map(({ id, icon: Icon, name, summary }, i) => (
        <Link className="service-card" to={`/demo?service=${id}`} key={id}>
          <div className="service-top">
            <Icon size={25} />
            <span>0{i + 1}</span>
          </div>
          <h3>{name}</h3>
          <p>{summary}</p>
          <span className="card-link">
            Try this service <ArrowUpRight size={15} />
          </span>
        </Link>
      ))}
    </div>
  );
}
function Home() {
  return (
    <>
      <section className="hero wrap">
        <div className="hero-copy">
          <div className="location" data-enter>
            <MapPin size={14} /> BUILT FOR DAR ES SALAAM
          </div>
          <h1 data-enter>
            Home fixes.
            <br />
            Minus the
            <br />
            <em>guesswork.</em>
          </h1>
          <p data-enter>
            From “what’s wrong?” to “fundi amefika.” Diagnose the issue, get a
            clear estimate, and follow the repair in one place.
          </p>
          <div className="actions" data-enter>
            <Button to="/demo">
              Try DetechX <ArrowUpRight size={18} />
            </Button>
            <Button to="/how-it-works" secondary>
              See how it works <ArrowRight size={17} />
            </Button>
          </div>
        </div>
        <div className="hero-visual" data-enter>
          <img
            className="poster"
            src="/hero.jpg"
            alt="A Dar es Salaam technician inspecting a wall-mounted air conditioner"
            fetchPriority="high"
          />
          <Aura />
          <div className="image-caption">
            <span>01 / FIELD NOTES</span>
            <span>DAR · TZ</span>
          </div>
          <div className="assistant-card">
            <span className="card-symbol">
              <Sparkles size={21} />
            </span>
            <div>
              <b>AI Diagnostic</b>
              <small>Possible airflow issue detected</small>
            </div>
          </div>
          <div className="route-card">
            <span className="card-symbol">
              <Radio size={21} />
            </span>
            <div>
              <b>Fundi yuko njiani</b>
              <small>Mikocheni, Dar es Salaam</small>
            </div>
            <span className="live-dot" aria-hidden="true" />
          </div>
        </div>
      </section>
      <div className="feature-strip wrap">
        <div>
          <Sparkles /> Guided diagnostics
        </div>
        <div>
          <MapPin /> Technician tracking
        </div>
        <div>
          <ShieldCheck /> Clear TZS estimates
        </div>
        <Link to="/services" aria-label="Explore service categories">
          <ArrowDown size={18} />
        </Link>
      </div>
      <section className="section wrap" id="services">
        <Eyebrow>CARE FOR YOUR SPACE</Eyebrow>
        <div className="section-head">
          <h2>
            Whatever needs fixing<span>.</span>
          </h2>
          <Link to="/services">
            Explore services <ArrowUpRight size={17} />
          </Link>
        </div>
        <ServicesGrid />
      </section>
      <section className="wrap editorial">
        <img
          src="/services.jpg"
          loading="lazy"
          alt="Sunlit home interior with a wall-mounted air conditioner"
        />
        <div>
          <Eyebrow>MADE FOR DAR</Eyebrow>
          <h2>
            Good help.
            <br />
            Closer to home<span>.</span>
          </h2>
          <p>
            A clearer way to connect households and local fundis, from the first
            question to the final repair.
          </p>
          <Button to="/partners" secondary>
            Explore the partner pilot <ArrowUpRight size={16} />
          </Button>
        </div>
      </section>
    </>
  );
}
function PageHeading({ eyebrow, title, copy }) {
  return (
    <div className="page-heading">
      <Eyebrow>{eyebrow}</Eyebrow>
      <h1 data-enter>
        {title}
        <span>.</span>
      </h1>
      <p data-enter>{copy}</p>
    </div>
  );
}
function Services() {
  return (
    <section className="wrap page">
      <PageHeading
        eyebrow="HOME CARE / DAR ES SALAAM"
        title="Find the right help"
        copy="Start with the service closest to your issue. Each opens a sample diagnostic you can customize."
      />
      <ServicesGrid />
      <p className="muted note">
        Estimates in the demo are illustrative, not a quote or a confirmed
        appointment.
      </p>
    </section>
  );
}
function How() {
  return (
    <section className="wrap page">
      <PageHeading
        eyebrow="THE DETECHX FLOW"
        title="From issue to resolution"
        copy="Three steps from understanding the problem to following your service visit."
      />
      <div className="steps">
        {steps.map(([title, copy], index) => (
          <article key={title}>
            <span>0{index + 1}</span>
            <h2>{title}</h2>
            <p>{copy}</p>
          </article>
        ))}
      </div>
      <Button to="/demo">
        Walk through the demo <ArrowUpRight size={17} />
      </Button>
    </section>
  );
}
function Partners() {
  return (
    <section className="wrap page">
      <PageHeading
        eyebrow="FOR LOCAL OPERATORS"
        title="Less chasing. More fixing"
        copy="A pilot concept for AC businesses, property managers, and service teams in Dar es Salaam."
      />
      <div className="steps">
        {[
          [
            "For dispatchers",
            "Make assignments and visit status easier to follow.",
          ],
          [
            "For fundis",
            "Keep the service issue and agreed scope clear before arriving.",
          ],
          [
            "For customers",
            "Show the estimate and completion status without another phone call.",
          ],
        ].map(([title, copy], index) => (
          <article key={title}>
            <span>0{index + 1}</span>
            <h2>{title}</h2>
            <p>{copy}</p>
          </article>
        ))}
      </div>
      <Button to="/demo">
        See the customer flow <ArrowUpRight size={17} />
      </Button>
    </section>
  );
}
function Demo() {
  const [query] = useSearchParams();
  const initial = services.find((s) => s.id === query.get("service"));
  const [id, setId] = useState(initial?.id ?? "cooling");
  const [issue, setIssue] = useState(initial?.issue ?? "");
  const [area, setArea] = useState(areas[0]);
  const [result, setResult] = useState(null);
  const [stage, setStage] = useState(-1);
  const submit = (event) => {
    event.preventDefault();
    if (!issue.trim()) return;
    setResult({ service: services.find((s) => s.id === id), area });
    setStage(-1);
  };
  return (
    <section className="wrap page">
      <PageHeading
        eyebrow="INTERACTIVE PREVIEW"
        title="Try a service request"
        copy="Explore a diagnostic estimate and technician visit. No booking is sent and no money is collected."
      />
      <div className="demo-grid">
        <form onSubmit={submit} className="demo-panel">
          <h2>Tell us what’s wrong</h2>
          <label>
            Service
            <select value={id} onChange={(e) => setId(e.target.value)}>
              {services.map((s) => (
                <option value={s.id} key={s.id}>
                  {s.name}
                </option>
              ))}
            </select>
          </label>
          <label>
            Neighborhood
            <select value={area} onChange={(e) => setArea(e.target.value)}>
              {areas.map((a) => (
                <option key={a}>{a}</option>
              ))}
            </select>
          </label>
          <label>
            What are you noticing?
            <textarea
              value={issue}
              onChange={(e) => setIssue(e.target.value)}
              placeholder="My AC is running but not cooling…"
              rows={4}
              required
              maxLength={600}
            />
          </label>
          <button className="button" disabled={!issue.trim()}>
            Show sample estimate <ArrowRight size={17} />
          </button>
        </form>
        <div className="demo-panel result-panel" aria-live="polite">
          <span className="card-symbol">
            <Sparkles size={22} />
          </span>
          {result ? (
            <>
              <Eyebrow>SAMPLE ESTIMATE</Eyebrow>
              <h2>{result.service.name}</h2>
              <p>{result.area} · Dar es Salaam</p>
              <strong className="price">
                TZS {money(result.service.range[0])} –{" "}
                {money(result.service.range[1])}
              </strong>
              <p>
                The range is based on the selected category. A professional
                inspection is needed for an actual quote.
              </p>
              {stage < 0 ? (
                <button
                  className="button secondary"
                  onClick={() => setStage(0)}
                >
                  Simulate a visit <ChevronRight size={17} />
                </button>
              ) : (
                <>
                  <ol className="timeline">
                    {stages.map((s, i) => (
                      <li key={s} className={i <= stage ? "done" : ""}>
                        {i < stage ? <Check size={15} /> : <Clock3 size={15} />}{" "}
                        {s}
                      </li>
                    ))}
                  </ol>
                  {stage < stages.length - 1 && (
                    <button
                      className="button secondary"
                      onClick={() => setStage((v) => v + 1)}
                    >
                      Next milestone <ChevronRight size={17} />
                    </button>
                  )}
                </>
              )}
            </>
          ) : (
            <>
              <h2>Your demo starts here</h2>
              <p>
                Submit a sample issue to see a service estimate and walk through
                the dispatch milestones.
              </p>
            </>
          )}
        </div>
      </div>
    </section>
  );
}
function Privacy() {
  return (
    <section className="wrap page narrow">
      <PageHeading
        eyebrow="THE WEBSITE DEMO"
        title="Your data stays with you"
        copy="The demo form runs in your browser. It does not transmit or save your issue, create bookings, request location permission, or collect money."
      />
      <p>
        No accounts or tracking analytics are configured in this site. Your
        hosting provider may retain standard server access logs when the site is
        deployed.
      </p>
      <Button to="/">
        Back home <ArrowRight size={16} />
      </Button>
    </section>
  );
}
function Missing() {
  return (
    <section className="wrap page">
      <PageHeading
        eyebrow="404 / NOT FOUND"
        title="This page moved"
        copy="You can return home to explore the DetechX website."
      />
      <Button to="/">
        Back home <ArrowRight size={16} />
      </Button>
    </section>
  );
}
function App() {
  const location = useLocation();
  const main = useRef(null);
  const first = useRef(true);
  useLayoutEffect(() => {
    const pathname = location.pathname;
    window.scrollTo(0, 0);
    if (!first.current) main.current.focus({ preventScroll: true });
    first.current = false;
    const pages = {
      "/": "Home fixes, minus the guesswork",
      "/services": "Home services",
      "/how-it-works": "How it works",
      "/partners": "For partners",
      "/demo": "Interactive demo",
      "/privacy": "Privacy",
    };
    document.title = `DetechX — ${pages[pathname] ?? "Page not found"}`;
    const media = gsap.matchMedia();
    media.add("(prefers-reduced-motion: no-preference)", () =>
      gsap.fromTo(
        main.current.querySelectorAll("[data-enter]"),
        { opacity: 0, y: 16 },
        {
          opacity: 1,
          y: 0,
          stagger: 0.065,
          duration: 0.55,
          ease: "power3.out",
        },
      ),
    );
    return () => media.revert();
  }, [location.pathname]);
  return (
    <>
      <a className="skip" href="#main">
        Skip to content
      </a>
      <Header />
      <main id="main" ref={main} tabIndex={-1}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/services" element={<Services />} />
          <Route path="/how-it-works" element={<How />} />
          <Route path="/partners" element={<Partners />} />
          <Route path="/demo" element={<Demo key={location.search} />} />
          <Route path="/privacy" element={<Privacy />} />
          <Route path="*" element={<Missing />} />
        </Routes>
      </main>
      <Footer />
    </>
  );
}

createRoot(document.getElementById("root")).render(
  <BrowserRouter>
    <App />
  </BrowserRouter>,
);
