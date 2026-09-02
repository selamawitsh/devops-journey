# Session 07 (2/5): ECR — Where Images Live

## Why a registry has to exist

A locally built image (`myapp:1.0`) sits in Docker's storage on the machine
that built it. ECS runs on AWS infrastructure that has never seen that machine.
There has to be a shared, addressable handoff point between "I built this" and
"someone else runs this." That's all a registry is.

## ECR — private, IAM-gated

Docker Hub is public: anyone can `docker pull nginx`. ECR is AWS's private
registry — authentication goes through IAM (see Session 3), not a
username/password. You get a temporary token, then push:

```
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

docker tag myapp:1.0 <account-id>.dkr.ecr.us-east-1.amazonaws.com/myapp:1.0
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/myapp:1.0
```

Same IAM reasoning as everything else in this course: a policy decides who can
push to a given repo. A CI pipeline's role might be allowed to push; a
developer's personal IAM user often isn't, on purpose.

## Push is not deploy

Pushing an image to ECR only places a new artifact in storage. It has **zero**
effect on anything currently running. A container keeps running whatever image
it was started from until something explicitly tells ECS to pull the new one —
a service update or a forced new deployment. This separation is what makes
pushing safe: you can push broken images all day and nothing goes down until
you actually deploy one.

## Tags — where real incidents come from

`latest` is a **mutable** tag. Pushing a new image to `latest` silently moves
what it points to. If a service is configured to always pull `latest`, a bad
push plus an unrelated deploy event can take down production with no clear
record of what changed.

Real-world practice:

1. Tag every image with something immutable and traceable — usually the **git
   commit SHA** (`geospatial-service:a1b2c3d`), not just a version number. Every
   image is now tied to an exact commit, permanently.
2. Turn on **tag immutability** on the ECR repository itself — once a tag
   exists, it can't be overwritten. You'd have to push a genuinely new tag.

This is also your rollback mechanism for free: point the task definition back
at the previous commit SHA's tag.

## Image scanning

ECR can scan every pushed image for known CVEs in its OS packages. Companies
commonly wire this into CI so a build with a critical vulnerability fails
before it can even be pushed — enforcing the "smaller image, smaller attack
surface" idea from the containers fundamentals doc, automatically.

