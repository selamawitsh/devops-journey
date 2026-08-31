# Session 8a · What Is Serverless & The Shape of a Lambda


## First, What Is an API?

An API is a messenger between two programs: one asks for something, the API carries the
request and brings back the answer — no need to know how the other side works.

**Think of a ride-hailing app when you book a car:**

| Step | What happens |
|---|---|
| The request | You (the app) tap "find a ride" — you don't phone a driver yourself |
| The messenger | The API carries your pickup/drop-off to the ride company's servers, finds a driver, brings back the car and price |
| The response | The driver/servers do the real work behind the scenes — you never see how |

Every time an app talks to a server, it's using an API. In this session, **API Gateway**
gives my own code its own address that can be called the same way.

## What "Serverless" Really Means

Serverless does **not** mean "no servers." It means **I don't manage them.** AWS
provisions, scales, and maintains the servers invisibly — I provide only my code.

| | Detail |
|---|---|
| **You bring code** | Just the function. No OS, no runtime setup, no capacity planning |
| **It scales itself** | One request or a million, AWS runs as many copies as needed, automatically |
| **You pay per use** | Charged only while the code runs. Idle costs nothing — scale to zero |

## AWS Lambda: A Cloud Function

Lambda runs one function when an event happens. I upload the code; AWS runs it.

```python
def handler(event, context):
    name = event['name']
    return {
        'message': f'Hi {name}!'
    }
```

| Piece | Meaning |
|---|---|
| `def handler(...)` | The function AWS calls when the trigger fires |
| `event` | The input data — who called, what they sent |
| `context` | Runtime info — time left, request ID |
| `event['name']` | Reading one value out of the input |
| `return { ... }` | The answer sent back to the caller |

**The whole contract:** an event comes in, code runs, a result goes out. No web server, no
ports, just the logic.


## Key Terms

- **Serverless** — a model where the cloud provider manages server provisioning/scaling, not the developer
- **Handler** — the function Lambda invokes when its trigger fires
- **Event** — the structured input data passed into a Lambda invocation
- **Scale to zero** — running (and billing) nothing at all when there's no traffic

