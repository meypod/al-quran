#!/bin/bash

flatpak-builder --user --install --force-clean build-dir linux/flatpak_manifest.yml
