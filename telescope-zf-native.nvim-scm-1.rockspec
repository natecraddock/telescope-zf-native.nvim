local MODREV, SPECREV = 'scm', '-1'
rockspec_format = '3.0'
package = 'telescope-zf-native.nvim'
version = MODREV .. SPECREV

description = {
  summary = 'native telescope bindings to zf for sorting results',
  labels = { 'neovim', 'plugin', 'telescope', 'zf' },
  homepage = 'https://github.com/natecraddock/telescope-zf-native.nvim',
  license = 'MIT',
}

dependencies = {
  'lua >= 5.1',
  'telescope.nvim',
}

source = {
  url = 'https://github.com/natecraddock/telescope-zf-native.nvim/archive/refs/tags/' .. MODREV .. '.zip',
  dir = 'telescope-fzf-native.nvim-' .. MODREV
}

if MODREV == 'scm' then
  source = {
    url = 'git://github.com/natecraddock/telescope-zf-native.nvim',
  }
end

build = {
  type = 'make',
  build_pass = false,
  install_variables = {
    INST_PREFIX='$(PREFIX)',
    INST_BINDIR='$(BINDIR)',
    INST_LIBDIR='$(LIBDIR)',
    INST_LUADIR='$(LUADIR)',
    INST_CONFDIR='$(CONFDIR)',
  },
}
