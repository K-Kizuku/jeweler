export const extractProjectId = (url: string): string | null => {
  const regex = /\/projects\/([a-zA-Z0-9]+)$/;
  const match = url.match(regex);
  return match ? match[1] : null;
};
