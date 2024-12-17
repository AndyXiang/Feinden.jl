module Consts 

export NAME_FROM_PDGID, MASS_FROM_PDGID

""" 
    Dictionary of getting particle name from PDG id.
"""
const NAME_FROM_PDGID = Dict(
    # quarks
    1 => "d",
    -1 => "dbar",
    2 => "u",
    -2 => "ubar",
    3 => "s",
    -3 => "sbar",
    4 => "c",
    -4 => "cbar",
    5 => "b",
    -5 => "bbar",
    6 => "t",
    -6 => "tbar",
    # leptons
    11 => "e-",
    -11 => "e+",
    12 => "ν_e",
    -12 => "νbar_e",
    13 => "μ-",
    -13 => "μ+",
    14 => "ν_μ",
    -14 => "νbar_μ",
    15 => "τ-",
    -15 => "τ+",
    16 => "ν_τ",
    -16 => "νbar_τ",
    # gauge bosons
    21 => "g",
    22 => "γ",
    23 => "Z",
    24 => "W+",
    -24 => "W-"
    # light I=1 mesons
)

""" 
    Dictionary of getting particle mass from PDG id. In units of GeV.
"""
const MASS_FROM_PDGID = Dict(
    # quarks
    1 => 4.67e-3,
    -1 => 4.67e-3,
    2 => 2.16e-3,
    -2 => 2.16e-3,
    3 => 93.4e-3,
    -3 => 93.4e-3,
    4 => 1.27,
    -4 => 1.27,
    5 => 4.18,
    -5 => 4.18,
    6 => 172.69,
    -6 => 172.69,
    # leptons
    11 => 0.51099895e-3,
    -11 => 0.51099895e-3,
    12 => 0,
    -12 => 0,
    13 => 105.6583755e-3,
    -13 => 105.6583755e-3,
    14 => 0,
    -14 => 0,
    15 => 1776.86e-3,
    -15 => 1776.86e-3,
    16 => 0,
    -16 => 0,
    # gauge bosons
    21 => 0,
    22 => 0,
    23 => 91.1876,
    24 => 80.377,
    -24 => 80.377
    # light I=1 mesons
)

end