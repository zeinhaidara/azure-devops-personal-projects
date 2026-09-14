var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

var version = Environment.GetEnvironmentVariable("APP_VERSION") ?? "dev";
var hostname = Environment.MachineName;

app.MapGet("/", () => Results.Content("""
    <!doctype html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Zein Release Console</title>
      <style>
        * { box-sizing: border-box; }
        body { margin: 0; min-height: 100vh; font-family: Arial, sans-serif; background: #070b1c; color: #dffcff; background-image: linear-gradient(#00f0ff0d 1px, transparent 1px), linear-gradient(90deg, #00f0ff0d 1px, transparent 1px); background-size: 32px 32px; }
        header { background: #10152d; color: #00f0ff; padding: 28px 8%; letter-spacing: 4px; text-shadow: 0 0 14px #00f0ff; border-bottom: 1px solid #00f0ff55; }
        main { max-width: 980px; margin: 38px auto; padding: 0 24px; }
        .hero { background: #10152ddd; border: 1px solid #ff2bd655; border-radius: 4px; padding: 42px; box-shadow: 0 0 28px #ff2bd633, inset 0 0 35px #00f0ff0d; }
        h1 { margin: 24px 0 10px; font-size: clamp(2.3rem, 6vw, 4.5rem); color: white; text-shadow: 0 0 18px #ff2bd6; }
        p { color: #9bb7c5; line-height: 1.6; }
        .cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(190px, 1fr)); gap: 16px; margin-top: 28px; }
        .card { border: 1px solid #00f0ff55; border-radius: 4px; padding: 20px; background: #071225; box-shadow: 0 0 12px #00f0ff18; }
        .value { font-size: 1.5rem; font-weight: 700; color: #00f0ff; text-shadow: 0 0 10px #00f0ff; }
        .badge { display: inline-block; background: #00f0ff; color: #070b1c; padding: 8px 14px; font-weight: bold; letter-spacing: 2px; box-shadow: 0 0 18px #00f0ff; }
        footer { text-align: center; color: #557080; margin: 28px; font-size: .85rem; letter-spacing: 2px; }
      </style>
    </head>
    <body>
      <header><strong>ZEIN RELEASE CONSOLE</strong></header>
      <main>
        <section class="hero">
          <span class="badge">DEPLOYMENT ONLINE</span>
          <h1>Ship fast. Run clean.</h1>
          <p>A compact release dashboard for the Zein Kubernetes lab. Every refresh shows which pod served your request.</p>
          <div class="cards">
            <div class="card"><div class="value">CI</div><p>Image built and tagged automatically</p></div>
            <div class="card"><div class="value">CD</div><p>Rolling release to shared AKS</p></div>
            <div class="card"><div class="value">__VERSION__</div><p>Pod: __HOSTNAME__</p></div>
          </div>
        </section>
      </main>
      <footer>Meridian Claims Platform · Internal demo</footer>
    </body>
    </html>
    """.Replace("__VERSION__", version).Replace("__HOSTNAME__", hostname), "text/html"));

app.MapGet("/health", () => Results.Ok(new { status = "healthy" }));

app.Run();
