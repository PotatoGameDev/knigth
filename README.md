# Game Design Document: The Wandering Knight

## Game Overview:

**Title:** The Wandering Knight

**Genre:** 2D Pixel Art Platformer with Metroidvania and Souls-like elements.

**Platform:** PC (potential for console release later)

**Engine:** Godot

**Art Style:** Pixel Art with a dark and mysterious atmosphere, reminiscent of Dark Souls' tone but simplified for 2D.

**Target Audience:** Players who enjoy challenging platformers and exploration, inspired by games like Hollow Knight, Celeste, and Dark Souls.

**Plot Summary:**
A knight, simply passing through, finds himself trapped in a strange and dangerous world. He is determined to escape, but to do so, he must defeat the powerful Final Boss who guards the exit. Along the way, the knight must also defeat a series of Mid Bosses, gaining strength and uncovering secrets to become strong enough to challenge the Final Boss.

## Core Gameplay:

### Movement and Controls:

**Walk:** Move left or right.

**Jump:** Single jump and unlockable double jump.

**Wall Jump:** Ability to jump off walls to reach higher or distant platforms.

**Attack:** Slash enemies with the knight's weapon. Holding down attack will charge a stronger blow but leaves the player vulnerable.

**Block:** Deflect incoming attacks, consuming stamina.

**Parry:** Time-based action while blocking that can stagger enemies, leaving them open to a counter-attack.

**Jump on Enemy:** Damages the opponent when the knight lands on an enemy's head.

## Game Structure:

### Level Design:

**Linear but Backtrackable:** The game world is linear but allows for backtracking. Certain areas will only be accessible after the knight unlocks specific skills or abilities, encouraging exploration.

**Secrets and Collectibles:** Hidden paths, items, and lore elements will be scattered throughout the game world, unlocked through exploration and skill upgrades.

## Skill System:

### Skills:

**Strength:** Increases attack power.

**Stamina:** Affects the number of consecutive attacks and overall movement speed.

**Jumping:** Increases jump height and unlocks additional double jumps for reaching previously inaccessible areas.

**Health:** Determines the knight's capacity to withstand damage from enemies.

### Debuffs System:

Risk-Reward Debuffs: Players can activate optional debuffs to earn additional stat increases, providing a customizable challenge.

**Example:** Tunnel Vision - The field of view is limited to a circle around the player, increasing the challenge but also providing a substantial movement speed boost.

## Enemies and Bosses:

### Enemies:

Varied enemy types with different attack patterns.

Enemies that require strategic approaches, including avoiding direct confrontation and instead using platforming (jumping on their heads).

### Mid Bosses:

Key bosses scattered throughout the game that must be defeated to progress.

Each mid-boss has unique attacks and strengths that will test the knight's skills.

### Final Boss:

The ultimate challenge, combining the lessons learned from each mid-boss encounter and requiring the use of all learned skills.

## Combat and Stamina System:

**Basic Attack:** Simple melee attack; can be charged for increased damage.

**Charged Attack:** Deals greater damage but leaves the player vulnerable while charging.

### Blocking and Parrying:

**Blocking:** Reduces incoming damage but consumes stamina.

**Parrying:** If timed correctly, parrying leaves enemies open to a counter-attack, providing a tactical advantage.

### Progression and Backtracking:

**Skill Upgrades:** Players earn experience points by defeating enemies and finding hidden collectibles, which they can use to upgrade their skills.

**Unlocking Paths:** Backtracking becomes crucial as the player gains new abilities (e.g., additional double jumps) that allow them to reach areas previously inaccessible.

**Secret Areas and Rewards:** Hidden items, lore pieces, or upgrades can be found by returning to earlier sections after acquiring new skills.

## Art and Sound Design:

**Visual Style:** Dark, atmospheric, pixel-art world with moody and oppressive environments.

**Soundtrack:** A mix of melancholic and tense tracks to emphasize the atmosphere of a world that doesn’t want the knight there.

**Sound Effects:** Distinct sounds for combat, movement, and environmental interactions. The sound design should make parrying, attacking, and receiving damage impactful.

## User Interface:

**Health Bar:** Displays the knight’s remaining health.

**Stamina Bar:** Indicates stamina available for attacking, blocking, and movement.

**Skill Menu:** Players can access this menu to view and upgrade skills, with descriptions and requirements for each upgrade.

## Additional Areas to Consider:

Enemy and Boss Design: What kinds of enemies would best fit the game world? Consider adding different classes of enemies (e.g., ranged, melee, magic-using).

### Narrative Elements: How will the story be told? Through dialogue, environmental storytelling, or collectible lore pieces?

**Level Variety:** Think about distinct regions or biomes within the game world that could change the gameplay or environment (e.g., swampy areas, castles, caverns).

**Save System:** Will there be save points (like bonfires in Dark Souls) or auto-save?

**NPCs:** Consider adding NPCs that the knight encounters along the way, perhaps offering guidance, lore, or items.

**Economy:** Will there be items or currency to collect? Can the knight trade or purchase upgrades, potions, or special items?

**Replayability:** Are there any features to encourage replaying the game (e.g., New Game Plus, alternate endings based on player choices)?

## Summary and Next Steps:
This GDD provides a basic structure and foundation for The Wandering Knight. The next steps would involve prototyping movement and combat, developing the art style, and fleshing out the skill and progression systems. Iterative testing will be crucial, especially for combat feel and the difficulty balance, to ensure it feels challenging but fair.
