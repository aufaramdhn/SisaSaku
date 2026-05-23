# Poppins Font Files

This directory should contain the following Poppins font files:

- `Poppins-Regular.ttf` (weight: 400)
- `Poppins-Medium.ttf` (weight: 500)
- `Poppins-SemiBold.ttf` (weight: 600)
- `Poppins-Bold.ttf` (weight: 700)

## How to Download

1. Visit [Google Fonts - Poppins](https://fonts.google.com/specimen/Poppins)
2. Click "Download family"
3. Extract the ZIP and copy the required `.ttf` files listed above into this directory

## Fallback

The project uses the `google_fonts` package (`google_fonts: ^6.1.0`) which can download
Poppins at runtime as a fallback. However, bundling the font files here ensures:

- Offline availability (no network needed for font loading)
- Faster initial text rendering (no download delay)
- No fallback-font warnings in the debug console
