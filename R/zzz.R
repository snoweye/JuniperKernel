# Copyright (C) 2017  Spencer Aiello
#
# This file is part of JuniperKernel.
#
# JuniperKernel is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# JuniperKernel is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with JuniperKernel.  If not, see <http://www.gnu.org/licenses/>.

.onAttach <- function(lib, pkg) {}

.onLoad <- function(libname, pkgname){
print(c(libname, pkgname))
  dn.pbdZMQ <- tools::file_path_as_absolute(
                 system.file("./libs", package = "pbdZMQ")) 
print(dn.pbdZMQ)
return(invisible())

  ### For osx only.
  if(Sys.info()[['sysname']] == "Darwin") {
    cmd.int <- system("which install_name_tool", intern = TRUE)
    cmd.ot <- system("which otool", intern = TRUE)

    ### Get rpath from pkg's shared library.
    fn.so <- paste(libname, "/", pkgname, "/libs/", pkgname, ".so", sep = "")
    rpath <- system(paste(cmd.ot, " -L ", fn.so, sep = ""),
                    intern = TRUE)

    ### Get dylib file from rpath
    pattern <- paste("^\\t(.*/pbdZMQ/libs/libzmq.*\\.dylib) .*$", sep = "")
    i.rpath <- grep(pattern, rpath)
    fn.dylib <- gsub(pattern, "\\1", rpath[i.rpath])

    ### Do nothing if the dylib file exists at which rpath points.
    ### Overwrite with one searched from path if the dylib file does not exist.
    if(length(fn.dylib) == 1) {
      if(!file.exists(fn.dylib)) {
        fn <- list.files(path = dn.pbdZMQ, pattern = "libzmq.*\\.dylib")
        new.fn.dylib <- paste(dn.pbdZMQ, "/", fn, sep = "")

        cmd <- paste(cmd.int, " -change ", fn.dylib, " ", new.fn.dylib,
                     " ", fn.so,
                     sep = "")
        system(cmd)
      }
    }
  }

  ### Load "pbdZMQ/libs/libzmq.*"
  fn <- list.files(path = dn.pbdZMQ, pattern = "libzmq\\..*")
  i.file <- paste(dn.pbdZMQ, "/", fn, sep = "")
  test <- try(dyn.load(i.file, local = FALSE), silent = TRUE)
  if(class(test) == "try-error"){
    stop(paste("Could not load ", i.file, ":",
               paste(test, collapse = ", "), sep = " "))
  }

  ### Load "pkgname.so".
  library.dynam("JuniperKernel", pkgname, libname)

  invisible()
} # End of .onLoad().
