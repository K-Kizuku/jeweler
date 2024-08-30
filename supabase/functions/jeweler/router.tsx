/** @jsxImportSource jsr:@hono/hono/jsx */
import { Hono } from "jsr:@hono/hono";
import { renderer, AddTodo, Item } from "./components.tsx";

// change this to your function name
const functionName = "jeweler";
const app = new Hono().basePath(`/${functionName}`);

app.get("*", renderer);

app.get("/hello", (c) => c.text("Hello from hono-server!"));

app.get("/", (c) => {
  return c.render(
    <div>
      <AddTodo />

      <div id="todo"></div>
    </div>
  );
});

export default app;
