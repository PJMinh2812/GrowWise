---
name: GrowWise Enterprise
colors:
  surface: '#fef7ff'
  surface-dim: '#dfd7e6'
  surface-bright: '#fef7ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f9f1ff'
  surface-container: '#f3ebfa'
  surface-container-high: '#ede5f4'
  surface-container-highest: '#e8dfee'
  on-surface: '#1d1a24'
  on-surface-variant: '#4a4455'
  inverse-surface: '#332f39'
  inverse-on-surface: '#f6eefc'
  outline: '#7b7487'
  outline-variant: '#ccc3d8'
  surface-tint: '#732ee4'
  primary: '#630ed4'
  on-primary: '#ffffff'
  primary-container: '#7c3aed'
  on-primary-container: '#ede0ff'
  inverse-primary: '#d2bbff'
  secondary: '#006c49'
  on-secondary: '#ffffff'
  secondary-container: '#6cf8bb'
  on-secondary-container: '#00714d'
  tertiary: '#704500'
  on-tertiary: '#ffffff'
  tertiary-container: '#905b00'
  on-tertiary-container: '#ffe1c0'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#eaddff'
  primary-fixed-dim: '#d2bbff'
  on-primary-fixed: '#25005a'
  on-primary-fixed-variant: '#5a00c6'
  secondary-fixed: '#6ffbbe'
  secondary-fixed-dim: '#4edea3'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#ffddb8'
  tertiary-fixed-dim: '#ffb95f'
  on-tertiary-fixed: '#2a1700'
  on-tertiary-fixed-variant: '#653e00'
  background: '#fef7ff'
  on-background: '#1d1a24'
  surface-variant: '#e8dfee'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  display-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  mono:
    fontFamily: ui-monospace
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  2xl: 48px
  container-max: 1440px
  sidebar-width: 280px
---

## Brand & Style
The design system focuses on a **Professional-Modern** aesthetic tailored for administrators managing children's financial education. It balances the serious nature of fintech with the approachable energy of an educational platform.

The style is rooted in **Minimalism** with a high degree of functional clarity. It uses generous white space, a structured grayscale, and intentional pops of violet to guide the user's attention. The interface should feel light, airy, and "uncluttered," even when displaying complex data sets. The emotional goal is to evoke a sense of **competence, security, and forward-thinking innovation.**

## Colors
The palette is designed for high legibility and quick status recognition.
- **Primary Violet:** Used for primary actions, active navigation states, and brand-defining moments.
- **Semantic Colors:** Green (Success/Growth), Yellow (Warning/Pending), and Red (Danger/Errors) follow industry standards for financial software to ensure zero-latency understanding of system states.
- **Neutral Surface:** The background uses a very subtle off-white (`#F9FAFB`) to reduce screen glare and distinguish the content area from the pure white (`#FFFFFF`) sidebar and card surfaces.

## Typography
This design system utilizes **Inter** for its exceptional legibility in data-heavy environments and its neutral, professional tone. 

The type hierarchy is strictly enforced to ensure tabular data and complex forms remain digestible. We use tighter letter spacing for large headlines to maintain a contemporary feel, while labels utilize a slightly heavier weight (`Medium` or `SemiBold`) at smaller sizes to ensure they remain distinct from body text. For transaction IDs or financial figures, a system monospace font may be used to ensure numerical alignment.

## Layout & Spacing
The layout follows a **Fixed-Fluid hybrid model**:
- **Sidebar:** Fixed width of 280px, pinned to the left.
- **Main Canvas:** A fluid area that expands to fill the screen but caps content at a 1440px max-width to prevent line lengths from becoming unreadable on ultra-wide monitors.
- **Grid:** A 12-column system is used within the main canvas for dashboard widgets and data views.
- **Rhythm:** An 8px base grid is used for all component-level spacing (gutters, margins, and padding) to ensure mathematical harmony and vertical rhythm.

## Elevation & Depth
In line with the minimalist philosophy, this design system uses a **low-depth model** to maintain a "flat but layered" feel. 

- **Level 0 (Surface):** The background layer (`#F9FAFB`).
- **Level 1 (Cards/Sidebar):** Pure white surfaces with a subtle `1px` border in `#E5E7EB`.
- **Level 2 (Shadows):** Only used for floating elements like dropdowns, tooltips, or modals. The shadow is an ambient, highly diffused blur: `0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)`. 

Interaction is communicated through color shifts rather than shadow depth to keep the interface feeling fast and modern.

## Shapes
The shape language is "Friendly Professional." 
- **Large Components (Cards, Modals):** Use a 12px (`rounded-lg`) radius to provide a soft, welcoming feel.
- **Small Components (Buttons, Inputs, Chips):** Use an 8px (`rounded-md`) radius to maintain a sense of precision and structure.
- **Full Rounding:** Reserved only for status badges and user avatars.

## Components

### Buttons
Primary buttons use the Violet color with white text. Secondary buttons use a white background with a gray-200 border. Transitions should be a fast 150ms ease-in-out on hover.

### Inputs & Selects
Use a white background with a 1px border (`#E5E7EB`). On focus, the border transitions to Primary Violet with a 2px semi-transparent violet glow. Labels are always positioned above the field in `label-sm`.

### Cards
Cards are the primary container for data. They must have a 12px border radius, a white background, and a 1px gray border. No shadows are used for static cards to keep the UI "flat."

### Data Tables
Tables are the heart of the admin experience. Use `body-sm` for row data. Headers should be uppercase `label-sm` with a light gray text color. Use subtle horizontal dividers only; avoid vertical lines to maximize horizontal scanability.

### Chips/Badges
Small, high-contrast labels for statuses. Success Green should have a light green background with dark green text for readability. Avoid using pure primary colors for badge backgrounds; always use a light tint.

### Sidebar Navigation
The sidebar should use the pure white background. Active states are indicated by a 3px vertical "indicator" on the far left in Primary Violet and a light violet background tint behind the menu item.