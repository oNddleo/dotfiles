#!/usr/bin/env nu
# Get packages from Brewfile
let brewfile_packages = (
    open Brewfile 
    | lines 
    | where { |line| $line | str starts-with "brew " } 
    | each { |line| $line | str replace 'brew "' '' | str replace '"' '' | str trim }
)

# Get all installed packages
let installed_packages = (brew list --formula | lines)

# Find packages to remove (installed but not in Brewfile)
let packages_to_remove = (
    $installed_packages 
    | where { |pkg| $pkg not-in $brewfile_packages }
)

# Remove the packages
if ($packages_to_remove | length) > 0 {
    print $"Removing ($packages_to_remove | length) packages not in Brewfile..."
    brew remove --force ...$packages_to_remove --ignore-dependencies
} else {
    print "All installed packages are in Brewfile"
}