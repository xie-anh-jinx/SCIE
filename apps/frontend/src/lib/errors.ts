/**
 * Parse API errors into a human-readable string.
 *
 * FastAPI can return:
 *   - string:  { "detail": "Email already registered" }
 *   - array:   { "detail": [{ "type": "...", "loc": [...], "msg": "...", "input": "...", "ctx": {...} }] }
 *   - network: AxiosError with no response
 */
export function parseApiError(err: unknown, fallback = 'Terjadi kesalahan. Coba lagi.'): string {
  if (!err || typeof err !== 'object') return fallback;

  const axiosErr = err as {
    response?: { data?: { detail?: unknown } };
    message?: string;
  };

  const detail = axiosErr?.response?.data?.detail;

  // Simple string message from backend
  if (typeof detail === 'string') return detail;

  // Pydantic v2 validation error array
  // e.g. [{ type, loc, msg, input, ctx }]
  if (Array.isArray(detail) && detail.length > 0) {
    return detail
      .map((e: unknown) => {
        if (typeof e === 'object' && e !== null && 'msg' in e) {
          const item = e as { msg: string; loc?: string[] };
          const field = item.loc ? item.loc.slice(-1)[0] : null;
          return field && field !== 'body'
            ? `${field}: ${item.msg}`
            : item.msg;
        }
        return String(e);
      })
      .join(' · ');
  }

  // Network / timeout error
  if (axiosErr?.message) return axiosErr.message;

  return fallback;
}
