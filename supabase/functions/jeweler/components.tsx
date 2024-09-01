/** @jsxImportSource jsr:@hono/hono/jsx */

import { html } from "jsr:@hono/hono/html";
import { jsxRenderer } from "jsr:@hono/hono/jsx-renderer";

export const renderer = jsxRenderer(({ children }) => {
  return html`
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <script src="https://unpkg.com/htmx.org@1.9.3"></script>
      <script src="https://unpkg.com/hyperscript.org@0.9.9"></script>
      <script src="https://cdn.tailwindcss.com"></script>
      <link
        rel="icon"
        type="image/png"
        href="https://kizuku-storage.work/jeweler-favicon.png"
      />
      <title>Jeweler</title>
    </head>
    <body>
      <div class="p-4">
        <h1 class="text-4xl font-bold mb-4"><a href="/">Todo</a></h1>
        ${children}
      </div>
    </body>
  `;
});

export const AddTodo = () => (
  <form
    hx-post="/topaz"
    hx-target="#topaz"
    hx-swap="beforebegin"
    _="on htmx:afterRequest reset() me"
    class="mb-6 bg-white shadow-md rounded-lg p-6"
  >
    <div class="mb-4">
      <label for="url" class="block text-gray-700 text-sm font-bold mb-2">
        URL
      </label>
      <input
        id="url"
        name="url"
        type="text"
        placeholder="Enter URL"
        class="bg-gray-50 border border-gray-300 text-gray-900 rounded-lg w-full p-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500"
        required
      />
    </div>

    <div class="mb-4">
      <label
        for="product_name"
        class="block text-gray-700 text-sm font-bold mb-2"
      >
        プロダクト名
      </label>
      <input
        id="product_name"
        name="product_name"
        type="text"
        placeholder="Enter Product Name"
        class="bg-gray-50 border border-gray-300 text-gray-900 rounded-lg w-full p-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500"
        required
      />
    </div>

    <button
      class="w-full text-white bg-blue-700 hover:bg-blue-800 rounded-lg px-5 py-2 text-center font-medium focus:outline-none focus:ring-2 focus:ring-blue-500"
      type="submit"
    >
      Submit
    </button>
  </form>
);

export const Item = ({ title, id }: { title: string; id: string }) => (
  <p
    hx-delete={`/todo/${id}`}
    hx-swap="outerHTML"
    class="flex row items-center justify-between py-1 px-4 my-1 rounded-lg text-lg border bg-gray-100 text-gray-600 mb-2"
  >
    {title}
    <button class="font-medium">Delete</button>
  </p>
);
