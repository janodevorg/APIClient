# What is a header?

A **header** is a pair of *field:type* used by client and server to negotiate the exchange of data.

There are several kinds of fields:

- [Representation header](https://datatracker.ietf.org/doc/html/rfc7231#section-3.1) fields
  provide type, encoding, language, and location metadata.

- [Request header](https://datatracker.ietf.org/doc/html/rfc7231#section-5) fields have several
  uses, e.g. negotiation, authentication, context, and others.

- [Response header](https://datatracker.ietf.org/doc/html/rfc7231#section-7) fields provide
  additional information about the response.

Types are formally known as media type or IANA media type. The Internet Assigned Numbers
Authority (IANA) keeps a
[registry of media types](https://www.iana.org/assignments/media-types/media-types.xhtml).

#### Example

Here are a couple of messages client and server usually exchange:
```
Client > Accept: application/json
Server > Content-Type: application/json
```

which we can disect as follows:

|  | Field | Type | Meaning |
|----|---|---|---|
| **Client** | Accept | application/json | I accept JSON documents |
| **Server** | Content-Type | application/json | This is a JSON document |

where the classificiation for each element is:

| | Classification |
|-|-|
| `Accept` | Content negotiation request header |
| `Content-Type` | Representation header |
| `application/json` | Media type |
