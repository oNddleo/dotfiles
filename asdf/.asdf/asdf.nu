let shims_dir = (
  (default ($env.HOME | path join '.asdf')) 
  | path join 'shims'
)

$env.PATH = (
  $env.PATH 
  | split row (char esep) 
  | where { |p| $p != $shims_dir } 
  | prepend $shims_dir
  | str join (char esep)
)