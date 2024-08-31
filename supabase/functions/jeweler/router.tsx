/** @jsxImportSource jsr:@hono/hono/jsx */
import { Hono } from "jsr:@hono/hono";
import { z } from "npm:zod";
import { zValidator } from "npm:@hono/zod-validator";

import { renderer, AddTodo, Item } from "./components.tsx";
import { extractProjectId } from "./utils.ts";

// change this to your function name
const functionName = "jeweler";
const app = new Hono().basePath(`/${functionName}`);

app.get("*", renderer);

app.get("/hello", (c) => c.text("Hello from hono-server!"));

app.get("/", (c) => {
  c.header("Content-Type", "text/html");
  return c.render(
    <div>
      <AddTodo />

      <div id="todo"></div>
    </div>
  );
});

app.post(
  "/topaz",
  zValidator(
    "form",
    z.object({
      url: z.string().min(1),
      name: z.string().min(1),
    })
  ),
  async (c) => {
    const { url, name } = c.req.valid("form");
    const id = extractProjectId(url);
    const result = await fetch(`https://topaz.dev/api/projects/${id}`);
    const data = await result.json();
    const res = await fetch(`https://topaz.dev/api/projects/${id}/todos`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ name: name, data: data }),
    });
    if (res.ok) {
      return c.html(<div>OK</div>);
    } else {
      c.status(500);
      return c.html(<div>Failed</div>);
    }
  }
);

export default app;
