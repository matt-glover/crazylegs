" To use this, you must define the global variable "g:project_root" to be the
" location of the root of your project.  

" Determine the project_root
if exists("g:pose")
"    let g:project_root="~/Projects/pose"
"    exec "set path=" . g:project_root . "/core/src/**," . g:project_root . "/report/src/**," . g:project_root . "/report/bin/**," . g:project_root . "/report/db/**," . g:project_root . "/content/**"
"    set grepprg=~/bin/pose_grep.sh\ $*
else
    if !exists("g:project_root")
        let g:project_root="~/Projects"
    endif
    exec "set path=" . g:project_root. "/**"
    set grepprg=grep\ -rn\ $*
endif

exec "map g :grep  " . g:project_root . "<Home><Right><Right><Right><Right><Right>"
exec "map  :grep <cword> " . g:project_root
exec "map G :grep <cword> " . g:project_root . ""

