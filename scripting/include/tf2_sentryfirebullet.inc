/** Double-include prevention */
#if defined _tf2_sentryfirebullet_included_
  #endinput
#endif
#define _tf2_sentryfirebullet_included_

enum // FireBulletsFlags_t
{
	FIRE_BULLETS_FIRST_SHOT_ACCURATE = 0x1,		// Pop the first shot with perfect accuracy
	FIRE_BULLETS_DONT_HIT_UNDERWATER = 0x2,		// If the shot hits its target underwater, don't damage it
	FIRE_BULLETS_ALLOW_WATER_SURFACE_IMPACTS = 0x4,	// If the shot hits water surface, still call DoImpactEffect
	FIRE_BULLETS_TEMPORARY_DANGER_SOUND = 0x8,		// Danger sounds added from this impact can be stomped immediately if another is queued
};

/**
 * Called before CBaseEntity::FireBullets().
 * 
 * @param sentry
 * @param builder
 * @param shots
 * @param src
 * @param dirShooting
 * @param spread				Spread of bullet fire.
 * @param distance
 * @param ammoType
 * @param tracerFreq
 * @param damage
 * @param playerDamage			Damage to be used instead of m_flDamage if we hit a player.
 * @param flags					See FireBulletsFlags_t.
 * @param damageForceScale
 * @param attacker
 * @param additionalIgnoreEnt
 * @param primaryAttack
 * @param useServerRandomSeed
 * 
 * @return	Plugin_Stop or Plugin_Handled to block shooting bullet.
 * 			Plugin_Changed to change parameters.
 * 			Plugin_Continue is nothing happen.
 */
forward Action TF2_SentryFireBullet(int sentry, int builder, int &shots, const float src[3], const float dirShooting[3], float spread[3], float &distance, int &ammoType, int &tracerFreq, float &damage, int &playerDamage, int &flags, float &damageForceScale, int &attacker, int &ignoreEnt, bool &primaryAttack, bool &useServerRandomSeed);

forward void TF2_SentryFireBulletPost(int sentry, int builder, int shots, const float src[3], const float dirShooting[3], const float spread[3], float distance, int ammoType, int tracerFreq, float damage, int playerDamage, int flags, float damageForceScale, int attacker, int ignoreEnt, bool primaryAttack, bool useServerRandomSeed);

public SharedPlugin __pl_tf2_sentryfirebullet = {
	name = "tf2_sentryfirebullet",
	file = "tf2_sentryfirebullet.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};
