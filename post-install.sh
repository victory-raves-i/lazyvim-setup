#!/bin/bash

# LazyVim Optional Tools Installation Script
# Installs additional tools for enhanced LazyVim features
# Based on :checkhealth output

set -e # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Function to detect OS
detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    VER=$(sw_vers -productVersion)
    print_info "Detected OS: macOS $VER"
  elif [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
    print_info "Detected OS: $OS $VER"
  else
    print_error "Cannot detect OS."
    exit 1
  fi
}

# Function to check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to install on macOS
install_macos() {
  print_info "Installing optional tools for macOS..."

  # Check if Homebrew is installed
  if ! command_exists brew; then
    print_error "Homebrew is not installed!"
    print_info "Please install Homebrew first: https://brew.sh"
    exit 1
  fi

  # Update Homebrew
  print_info "Updating Homebrew..."
  brew update

  # 2. Install ImageMagick (for image conversion)
  print_info "Installing ImageMagick (image processing)..."
  if ! command_exists magick && ! command_exists convert; then
    brew install imagemagick
    print_success "ImageMagick installed!"
  else
    print_success "ImageMagick already installed"
  fi

  # 3. Install Ghostscript (for PDF rendering)
  print_info "Installing Ghostscript (PDF rendering)..."
  if ! command_exists gs; then
    brew install ghostscript
    print_success "Ghostscript installed!"
  else
    print_success "Ghostscript already installed"
  fi

  # 4. Install Tectonic (modern LaTeX engine - easier than full TeX Live)
  print_info "Installing Tectonic (LaTeX rendering)..."
  if ! command_exists tectonic; then
    brew install tectonic
    print_success "Tectonic installed!"
  else
    print_success "Tectonic already installed"
  fi

  # 5. Install Mermaid CLI (for diagram rendering)
  print_info "Installing Mermaid CLI (diagram rendering)..."
  if ! command_exists mmdc; then
    # Check if npm is installed
    if ! command_exists npm; then
      print_info "Installing Node.js first..."
      brew install node
    fi
    npm install -g @mermaid-js/mermaid-cli
    print_success "Mermaid CLI installed!"
  else
    print_success "Mermaid CLI already installed"
  fi

  print_success "All optional tools installed successfully!"
}

# Function to install on Ubuntu/Debian
install_debian() {
  print_info "Installing optional tools for Debian/Ubuntu..."

  sudo apt update

  # 1. Install WezTerm
  print_info "Installing WezTerm..."
  if ! command_exists wezterm; then
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
    echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
    sudo apt update
    sudo apt install -y wezterm
    print_success "WezTerm installed!"
  else
    print_success "WezTerm already installed"
  fi

  # 2. Install ImageMagick
  print_info "Installing ImageMagick..."
  sudo apt install -y imagemagick

  # 3. Install Ghostscript
  print_info "Installing Ghostscript..."
  sudo apt install -y ghostscript

  # 4. Install Tectonic
  print_info "Installing Tectonic..."
  if ! command_exists tectonic; then
    # Tectonic is not in standard repos, install from binary
    curl --proto '=https' --tlsv1.2 -fsSL https://drop-sh.fullyjustified.net | sh
    print_success "Tectonic installed!"
  else
    print_success "Tectonic already installed"
  fi

  # 5. Install Mermaid CLI
  print_info "Installing Mermaid CLI..."
  if ! command_exists npm; then
    print_info "Installing Node.js first..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
  fi
  sudo npm install -g @mermaid-js/mermaid-cli

  print_success "All optional tools installed successfully!"
}

# Function to install on Fedora
install_fedora() {
  print_info "Installing optional tools for Fedora..."

  # 1. Install WezTerm
  print_info "Installing WezTerm..."
  if ! command_exists wezterm; then
    sudo dnf copr enable -y wezfurlong/wezterm-nightly
    sudo dnf install -y wezterm
    print_success "WezTerm installed!"
  else
    print_success "WezTerm already installed"
  fi

  # 2. Install ImageMagick
  print_info "Installing ImageMagick..."
  sudo dnf install -y ImageMagick

  # 3. Install Ghostscript
  print_info "Installing Ghostscript..."
  sudo dnf install -y ghostscript

  # 4. Install Tectonic
  print_info "Installing Tectonic..."
  if ! command_exists tectonic; then
    curl --proto '=https' --tlsv1.2 -fsSL https://drop-sh.fullyjustified.net | sh
    print_success "Tectonic installed!"
  else
    print_success "Tectonic already installed"
  fi

  # 5. Install Mermaid CLI
  print_info "Installing Mermaid CLI..."
  if ! command_exists npm; then
    sudo dnf install -y nodejs npm
  fi
  sudo npm install -g @mermaid-js/mermaid-cli

  print_success "All optional tools installed successfully!"
}

# Function to install on Arch Linux
install_arch() {
  print_info "Installing optional tools for Arch Linux..."

  sudo pacman -Sy

  # 1. Install WezTerm
  print_info "Installing WezTerm..."
  sudo pacman -S --noconfirm --needed wezterm

  # 2. Install ImageMagick
  print_info "Installing ImageMagick..."
  sudo pacman -S --noconfirm --needed imagemagick

  # 3. Install Ghostscript
  print_info "Installing Ghostscript..."
  sudo pacman -S --noconfirm --needed ghostscript

  # 4. Install Tectonic
  print_info "Installing Tectonic..."
  sudo pacman -S --noconfirm --needed tectonic

  # 5. Install Mermaid CLI
  print_info "Installing Mermaid CLI..."
  if ! command_exists npm; then
    sudo pacman -S --noconfirm --needed nodejs npm
  fi
  sudo npm install -g @mermaid-js/mermaid-cli

  print_success "All optional tools installed successfully!"
}

# Function to verify installations
verify_installations() {
  print_info "Verifying installations..."
  echo ""

  # Check WezTerm
  if command_exists wezterm; then
    print_success "WezTerm: $(wezterm --version)"
  else
    print_warning "WezTerm: NOT FOUND"
  fi

  # Check ImageMagick
  if command_exists magick || command_exists convert; then
    if command_exists magick; then
      print_success "ImageMagick: $(magick --version | head -n1)"
    else
      print_success "ImageMagick: $(convert --version | head -n1)"
    fi
  else
    print_warning "ImageMagick: NOT FOUND"
  fi

  # Check Ghostscript
  if command_exists gs; then
    print_success "Ghostscript: $(gs --version)"
  else
    print_warning "Ghostscript: NOT FOUND"
  fi

  # Check Tectonic
  if command_exists tectonic; then
    print_success "Tectonic: $(tectonic --version)"
  else
    print_warning "Tectonic: NOT FOUND"
  fi

  # Check Mermaid CLI
  if command_exists mmdc; then
    print_success "Mermaid CLI: $(mmdc --version)"
  else
    print_warning "Mermaid CLI: NOT FOUND"
  fi
}

# Main installation flow
main() {
  echo "╔═══════════════════════════════════════════════════════════╗"
  echo "║     LazyVim Optional Tools Installation Script           ║"
  echo "╚═══════════════════════════════════════════════════════════╝"
  echo ""

  # Detect OS
  detect_os

  echo ""
  print_info "This script will install the following optional tools:"
  echo "  - ImageMagick (image processing and conversion)"
  echo "  - Ghostscript (PDF rendering)"
  echo "  - Tectonic (LaTeX rendering for math expressions)"
  echo "  - Mermaid CLI (diagram rendering)"
  echo ""
  print_warning "These are OPTIONAL but enhance LazyVim's functionality"
  echo ""

  read -p "Do you want to continue? (y/N): " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Installation cancelled."
    exit 0
  fi

  # Install based on detected OS
  case $OS in
  macos)
    install_macos
    ;;
  ubuntu | debian | linuxmint | pop)
    install_debian
    ;;
  fedora | rhel | centos)
    install_fedora
    ;;
  arch | manjaro | endeavouros)
    install_arch
    ;;
  *)
    print_error "Unsupported OS: $OS"
    exit 1
    ;;
  esac

  echo ""
  verify_installations

  echo ""
  print_success "Installation complete!"
  echo ""
  print_info "Next steps:"
  echo "  1. Switch to WezTerm terminal for full graphics support"
  echo "  2. Restart Neovim"
  echo "  3. Run :checkhealth in Neovim to verify"
  echo "  4. Missing Treesitter languages will auto-install when you open those file types"
  echo ""
  if [[ "$OS" == "macos" ]]; then
    print_warning "On macOS, you may need to add WezTerm to your dock or applications folder"
    print_info "Launch WezTerm from Applications or run 'wezterm' in terminal"
  fi
}

# Run main function
main
