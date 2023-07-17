# [TF2] Sentry-FireBullet
Hook Sentrygun's bullet fire.

## Forwards
You will get two forwards.
```
forward Action TF2_SentryFireBullet(int sentry, int builder, int &shots, const float src[3], const float dirShooting[3], float spread[3], float &distance, int &ammoType, int &tracerFreq, float &damage, int &playerDamage, int &flags, float &damageForceScale, int &attacker, int &ignoreEnt, bool &primaryAttack, bool &useServerRandomSeed);
```
```
forward void TF2_SentryFireBulletPost(int sentry, int builder, int shots, const float src[3], const float dirShooting[3], const float spread[3], float distance, int ammoType, int tracerFreq, float damage, int playerDamage, int flags, float damageForceScale, int attacker, int ignoreEnt, bool primaryAttack, bool useServerRandomSeed);
```

## Parameter(As far as I know)
- `shots`: Amounts of bullet per fire. If you set this to 5, sentry will fire 5 bullets per fire.
- `spread[3]`: Vector of spread.
- `distance`: Distance of bullet's max reach.
- `tracerFreq`: Tracer's Frequency.
- `damage` and `playerDamage`: Bullet's damage. But if victim is player, game will use playerDamage instead of damage.
- `flags`: Check out `FireBulletsFlags_t` in tf2_sentryfirebullet.inc.
- `damageForceScale`: Bullet's force scale.
- `attacker`: Attacker. Default value is builder's index.
- `ignoreEnt`: Define target who bullet will ignore. Default value is -1(none). 
----

## Building

This project is configured for building via [Ninja][]; see `BUILD.md` for detailed
instructions on how to build it.

If you'd like to use the build system for your own projects,
[the template is available here](https://github.com/nosoop/NinjaBuild-SMPlugin).

[Ninja]: https://ninja-build.org/
