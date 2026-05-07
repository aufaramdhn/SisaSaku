# SisaSaku Project Context

## What is this?

Flutter mobile app — personal finance tracker + bill reminder.
Offline-first. Indonesian market. Clean Architecture.

## Stack

Flutter + Isar + Riverpod + flutter_local_notifications + Supabase (optional cloud)

## Architecture Pattern

Feature-first Clean Architecture:
features/<name>/
data/ → models (@collection Isar), datasources, repository_impl
domain/ → entities, usecases, abstract repository
presentation/ → pages, widgets, providers

## Features

- dashboard → saldo card, tagihan terdekat, transaksi terbaru
- transaction → quick entry bottom sheet, CRUD
- bill → reminder dengan local notification, status: overdue/upcoming/paid
- analytics → bar chart 7 hari, breakdown per kategori
- category → CRUD kategori dengan ikon & warna
- auth → Supabase Auth (Google/Email), mode guest jika belum login
- settings → ekspor CSV/PDF, cloud backup toggle

## Design Tokens

Primary: #1D9E75 (teal)
Warning: #EF9F27 (amber)
Danger: #E24B4A (red)
Success: #3B6D11 (green)
BG: #F4F6F8
Font: Plus Jakarta Sans

## Bottom Navigation

5 items: Beranda | Analitik | [Catat — center notched FAB] | Tagihan | Pengaturan

## Data Models

transaksi: id, nominal, jenis (in/out), tanggal, id_kategori, deskripsi, sync_status
kategori: id, nama, ikon, warna
tagihan: id, nama, nominal, tanggal_jatuh_tempo, waktu_pengingat, sync_status

## Important Rules

- Domain layer: zero Flutter/external imports
- All features work 100% offline
- Currency: always Rupiah format (Rp 1.500.000)
- Sync: upload data where sync_status=false to Supabase after login
