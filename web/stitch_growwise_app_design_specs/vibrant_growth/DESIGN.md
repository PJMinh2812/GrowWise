---
name: Vibrant Growth
colors:
  surface: '#f9f9ff'
  surface-dim: '#cfdaf2'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eeff'
  surface-container-high: '#dee8ff'
  surface-container-highest: '#d8e3fb'
  on-surface: '#111c2d'
  on-surface-variant: '#584237'
  inverse-surface: '#263143'
  inverse-on-surface: '#ecf1ff'
  outline: '#8c7164'
  outline-variant: '#e0c0b1'
  surface-tint: '#9d4300'
  primary: '#9d4300'
  on-primary: '#ffffff'
  primary-container: '#f97316'
  on-primary-container: '#582200'
  inverse-primary: '#ffb690'
  secondary: '#4648d4'
  on-secondary: '#ffffff'
  secondary-container: '#6063ee'
  on-secondary-container: '#fffbff'
  tertiary: '#006e2f'
  on-tertiary: '#ffffff'
  tertiary-container: '#00b251'
  on-tertiary-container: '#003b16'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdbca'
  primary-fixed-dim: '#ffb690'
  on-primary-fixed: '#341100'
  on-primary-fixed-variant: '#783200'
  secondary-fixed: '#e1e0ff'
  secondary-fixed-dim: '#c0c1ff'
  on-secondary-fixed: '#07006c'
  on-secondary-fixed-variant: '#2f2ebe'
  tertiary-fixed: '#6bff8f'
  tertiary-fixed-dim: '#4ae176'
  on-tertiary-fixed: '#002109'
  on-tertiary-fixed-variant: '#005321'
  background: '#f9f9ff'
  on-background: '#111c2d'
  surface-variant: '#d8e3fb'
typography:
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '800'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '800'
    lineHeight: '1.2'
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1.3'
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '500'
    lineHeight: '1.6'
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  label-bold:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '700'
    lineHeight: '1'
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  gutter: 16px
  margin-mobile: 20px
  margin-desktop: 40px
  touch-target: 48px
---

## Brand & Style

This design system employs a dual-persona strategy. For the "Kid" side of the interface, the style shifts into a high-energy, **vibrant orange** theme designed to feel playful, motivating, and approachable. It sits at the intersection of **Minimalism** and **Tactile** design, utilizing large touch targets and generous whitespace to ensure ease of use for younger audiences while maintaining the sophisticated underlying structure of the broader platform.

The emotional response should be one of "enthusiastic achievement." The UI uses bold color blocks and clear visual metaphors to guide children through their journey, ensuring the experience feels like a game rather than a chore.

## Colors

The "Kid" experience is anchored by a primary **Vibrant Orange (#F97316)**. This color is used for all primary actions, progress indicators, and celebratory UI states to drive engagement and visual heat.

- **Primary (Orange):** Used for CTA buttons, active states, and success milestones.
- **Secondary (Indigo):** Reserved for "Parental" bridges or cross-over features, maintaining a subtle link to the adult side of the app.
- **Success (Green):** Used specifically for completed tasks and earned rewards.
- **Neutral:** A deep slate for typography to ensure AA/AAA contrast against the bright orange and white backgrounds.

Backgrounds should remain primarily white or very light gray (#F8FAFC) to let the orange accents pop without causing visual fatigue.

## Typography

This design system utilizes **Plus Jakarta Sans** across all levels to maintain a soft, rounded, and welcoming aesthetic. For the kid-centric side, weight is prioritized over scale to ensure high legibility. 

- **Headlines:** Use ExtraBold (800) weights for primary titles to create a sense of fun and impact.
- **Body:** Slightly larger default sizes (18px for primary body) facilitate easier reading for developing eyes.
- **Case:** Use sentence case for headlines to remain approachable, but use all-caps for "Label-bold" roles (like chips or small tags) to provide clear hierarchy.

## Layout & Spacing

The layout follows a **fluid grid** model with an emphasis on vertical stackability. 

- **Safe Zones:** A minimum margin of 20px on mobile ensures interactive elements are not too close to screen edges.
- **Touch Targets:** All interactive elements must adhere to a minimum 48x48px footprint.
- **Rhythm:** Use an 8px base unit. Component internal padding should be 16px (2x) or 24px (3x) to maintain a spacious, non-cluttered feel that reduces cognitive load for children.

## Elevation & Depth

To maintain the kid-friendly tactile feel, the design system uses **Tonal Layers** combined with **Soft Ambient Shadows**. 

1. **Surface Level:** The main background is flat.
2. **Card Level:** Cards use a subtle, 1px border in a darker tint of the background color and a soft, low-opacity shadow (Color: Primary-Orange at 10% opacity, 12px blur).
3. **Active Level:** Primary buttons use a "pressed" effect—moving from a soft shadow to a zero-offset state to simulate a physical push.

Avoid heavy blurs or glassmorphism which can distract from the content. Stick to solid, high-contrast shapes.

## Shapes

The shape language is defined as **Rounded**. 

- **Standard Elements:** Use 0.5rem (8px) for buttons and input fields.
- **Containers:** Large cards and modals use `rounded-xl` (1.5rem / 24px) to create a friendly, "bubbly" container feel.
- **Icons:** Should always be enclosed in a rounded square or circle container to maintain the soft-edged aesthetic.

## Components

### Buttons
Primary buttons are solid Vibrant Orange with white text. They should have a "chunky" feel with 16px vertical padding. Secondary buttons use an Orange outline with a 2px stroke.

### Cards
Cards are the primary container for tasks and lessons. They use a white background with an 8px bottom border in a darker orange shade to give them a 3D, tactile "tile" appearance.

### Chips & Badges
Used for categories or reward counts. These should use high-contrast combinations: light orange backgrounds with dark orange text.

### Progress Bars
The track should be a soft gray-orange, while the indicator is the solid Vibrant Orange. Use a `rounded-xl` setting for the progress bar to make it look friendly and significant.

### Input Fields
Inputs should have a 2px border that turns solid Orange when focused. Labels stay above the field in Bold Slate for maximum readability.