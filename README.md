[![Coverage Status](https://coveralls.io/repos/github/Seunadex/focushub/badge.svg?branch=main&refresh=1)](https://coveralls.io/github/Seunadex/focushub?branch=main)
[![CI](https://github.com/Seunadex/focushub/actions/workflows/ci.yml/badge.svg)](https://github.com/Seunadex/focushub/actions/workflows/ci.yml)
# FocusHub

Tasks + Habits in one fast, motivating dashboard. Built with **Rails 8**, **Hotwire (Turbo + Stimulus)**, and **Tailwind CSS**. Track daily work, build routines, celebrate streaks, and keep each other accountable in **Groups**.

---

## ✨ Features

- **Tasks**
  - Quick add / inline complete
  - Priorities, due dates, pagination (Pagy)
  - Turbo Streams for instant list updates
- **Habits**
  - Daily / Weekly / Monthly (and more) with **targets**
  - **Progress %** per period and **current/best streaks**
  - Pause/Archive habits without losing history
- **Groups**
  - Invite members via email or share-link (private-group friendly)
  - Unified activity feed (task & habit milestones, joins/leaves)
  - Real-time updates with Turbo broadcasts
- **Auth & Roles**
  - Devise authentication
  - Role-based group membership (owner/admin/member)
- **Jobs & Scheduling**
  - **Solid Queue** (DB-backed Active Job) for mailers & nightly recalcs

---

## 🧱 Tech Stack

Rails 8 • Hotwire (Turbo/Stimulus) • Tailwind CSS • Pagy • Devise • Solid Queue • PostgreSQL • Docker (optional)

---

## 🚀 Quick Start

### Prerequisites
- Ruby 3.3+
- PostgreSQL 13+
- Node 18+ (if using esbuild)
- Yarn or npm

### Setup

```bash
# Install gems
bundle install

# DB setup (create, migrate, seed optional)
bin/rails db:setup

# Frontend (only once if not already installed)
bin/rails javascript:install:esbuild
bin/rails tailwindcss:install

# Run (Rails + JS/CSS watchers)
bin/dev
# or classic
bin/rails s