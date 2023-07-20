# [TF2] Sentry-FireBullet
Hook Sentrygun's bullet fire.

## Forwards
You will get two forwards.
```
forward Action TF2_SentryFireBullet(int sentry, int builder, int &shots, const float src[3], const float dirShooting[3], float spread[3], float &distance, int &tracerFreq, float &damage, int &playerDamage, int &flags, float &damageForceScale, int &attacker, int &ignoreEnt);
```
```
forward void TF2_SentryFireBulletPost(int sentry, int builder, int shots, const float src[3], const float dirShooting[3], const float spread[3], float distance, int tracerFreq, float damage, int playerDamage, int flags, float damageForceScale, int attacker, int ignoreEnt);
```
----

## Building

This project is configured for building via [Ninja][]; see `BUILD.md` for detailed
instructions on how to build it.

If you'd like to use the build system for your own projects,
[the template is available here](https://github.com/nosoop/NinjaBuild-SMPlugin).

[Ninja]: https://ninja-build.org/
