;;; vagramp.el --- Vagrant method for tramp

;; Author: Weslleymberg Lisboa <wesllym.lisboa@gmail.com>
;; URL: https://github.com/weslleymberg/vagramp/vagramp.el
;; Keywords: vagrant, environment

;; This file is not part of GNU Emacs.

;;; License:
;;
;; Copyright (C) 2018  Weslleymberg Lisboa
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; **NOTE**
;; vagramp relies on `vagrant` command being on your path.
;;
;; ## Usage
;; /vagrant:<machine-id>:/path/to/file
;;

;;; Code:
(require 'tramp)

(defgroup vagramp nil
  "Tramp method for Vagrant boxes."
  :prefix "vagramp-"
  :group 'environment
  :link '(url-link :tag "Github" "https://github.com/weslleymberg/vagramp.git"))

;;;###autoload
(defcustom vagramp-executable "vagrant"
  "Path to vagrant executable."
  :type 'string
  :group 'vagramp)

(defconst vagramp-command "global-status"
  "Vagrant command to execute.")

(defmacro vagramp--line-match-p (line)
  "True if LINE begins with a 7 chars word."
  `(string-match-p "^\\w\\{7\\}" ,line))

(defun vagramp--filter-lines (lines)
  "Filters matching LINES."
  (let ((valid-lines '()))
    (mapc #'(lambda (line)
               (when (vagramp--line-match-p line)
                 (push line valid-lines)))
            lines)
    valid-lines))

(defun vagramp--available-machines ()
  "Return a list containing the properties of all machines as a list."
  (mapcar 'split-string (vagramp--filter-lines (process-lines vagramp-executable vagramp-command))))

;;;###autoload
(defun vagramp--get-completion-candidates (&optional ignored)
  "Return a list of (nil host) for tramp completion.
Tramp calls this function with a filename which is IGNORED."
  (cl-loop for (id) in (vagramp--available-machines)
           collect (list nil id)))

;;;###autoload
(eval-after-load 'tramp
  '(progn
     (add-to-list 'tramp-methods
                  `("vagrant"
                    (tramp-login-program ,(concat vagramp-executable " ssh"))
                    (tramp-login-args (("%h")))
                    (tramp-remote-shell "/bin/sh")
                    (tramp-remote-shell-args ("-i" "-c"))))
     (tramp-set-completion-function "vagrant" '((vagramp--get-completion-candidates "")))))

(provide 'vagramp)

;;; vagramp.el ends here

