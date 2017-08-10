#!/bin/bash

# apex.sh - A shell script to find installed SBo packages on which no other
# installed packages depend.

# Copyright 2017  Chris Abela <kristofru@gmail.com>, Malta
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# List all the installed SBo packages and check them sequentially inside the
# queue files of all the other SBo packages
CONF=${CONF:-/etc/sbopkg/sbopkg.conf}
source $CONF
cd /var/log/packages/
# Get a list of SBo installed packages
SBP=$( ls *SBo 2>/dev/null |\
  sed "s/-[^-]*-[^-]*-[^-]*$//" )
for PKG in $SBP; do
  # From the installed SBo packages, we keep the ones that have an SQF file
  if [ -e ${QUEUEDIR}/${PKG}.sqf ]; then
    SBPSQF="$SBPSQF $PKG"
  else echo "WARNING: No Queue file was found for $PKG"
  fi
done
for PKG1 in $SBPSQF; do
  # Check if we have PKG1 in the Queue files
  # Let ACC contain the contents of files we will
  unset ACC
  for PKG2 in $SBPSQF; do
    if [ $PKG1 != $PKG2 ]; then
      # Anything after # or | shall be oblitarated
      ACC="$ACC $( sed 's/#.*$//
        s/|.*//' \
        ${QUEUEDIR}/${PKG2}.sqf )"
    fi
  done
  if  ! echo "$ACC" | egrep -q "^@${PKG1}$|^@${PKG1} | @${PKG1}$| @${PKG1} |^${PKG1}$|^${PKG1} | ${PKG1}$| ${PKG1} "
  then
    echo $PKG1
  fi
done
