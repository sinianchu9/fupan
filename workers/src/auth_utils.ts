export async function signJwtHS256(
  payload: any,
  secret: string
): Promise<string> {
  const header = { alg: "HS256", typ: "JWT" };
  const encodedHeader = b64(JSON.stringify(header));
  const encodedPayload = b64(JSON.stringify(payload));
  const data = `${encodedHeader}.${encodedPayload}`;

  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signature = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(data)
  );

  const encodedSignature = b64url(signature);
  return `${data}.${encodedSignature}`;
}

export async function verifyJwtHS256(
  token: string,
  secret: string,
  issuer: string,
  audience: string
): Promise<any | null> {
  const parts = token.split(".");
  if (parts.length !== 3) return null;

  const [headerB64, payloadB64, signatureB64] = parts;
  const data = `${headerB64}.${payloadB64}`;

  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["verify"]
  );

  const signature = deb64url(signatureB64);
  const isValid = await crypto.subtle.verify(
    "HMAC",
    key,
    signature as any,
    new TextEncoder().encode(data)
  );

  if (!isValid) return null;

  const payload = JSON.parse(new TextDecoder().decode(deb64(payloadB64)));

  const now = Math.floor(Date.now() / 1000);
  if (payload.iss !== issuer) return null;
  if (payload.aud !== audience) return null;
  if (payload.exp && payload.exp < now) return null;
  if (payload.iat && payload.iat > now) return null;

  return payload;
}

export async function hashOtp(code: string, salt: string, pepper: string): Promise<string> {
  // Combine code, salt, and pepper for hashing
  const msgUint8 = new TextEncoder().encode(`${code}:${salt}:${pepper}`);
  const hashBuffer = await crypto.subtle.digest("SHA-256", msgUint8);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
}

function b64(str: string): string {
  return btoa(str).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
}

function deb64(str: string): Uint8Array {
  const base64 = str.replace(/-/g, "+").replace(/_/g, "/");
  const binString = atob(base64);
  return Uint8Array.from(binString, (m) => m.codePointAt(0)!);
}

function b64url(buffer: ArrayBuffer): string {
  const binary = String.fromCharCode(...new Uint8Array(buffer));
  return btoa(binary).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
}

function deb64url(str: string): Uint8Array {
  return deb64(str);
}
