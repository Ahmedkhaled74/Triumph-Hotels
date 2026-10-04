# Project-Scoped Rules

## Responsive Design
All new screens and components must be fully responsive across mobile, tablet, and desktop devices.
When creating new UI files:
1. Always import and use `ResponsiveUtils` (`package:triumph_hotels/core/utils/responsive_utils.dart`).
2. Adjust root layout padding and constraints based on screen size (e.g., using `ResponsiveUtils.isSmallScreen(context)` or dynamic width percentages).
3. Ensure components like grids (`GridView`) dynamically adjust column counts (e.g., 2 columns on mobile, 3 on tablet, 4 on desktop).
4. Scale fonts and heights for prominent UI cards or elements if needed using `ResponsiveUtils` helpers.
