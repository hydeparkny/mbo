#set -x
# add an entry to the mobileBookmarkOverflow.html gist 
# at gist.github.com/hydeparkny
OSTYPE="$(uname -o)"
case ${OSTYPE} in
"Android")
# this assumes the Termux environment
TEMPDIR=$(dirname ${HOME})"/usr/tmp"
;;
"GNU/Linux")
TEMPDIR="/tmp"
;;
*)
echo "unknown OS type ${OSTYPE}"
exit 1
;;
esac
# omit quotes to permit tilde expansion
MBO_CREDS=~/.creds/mbo.gist
# not really a password , just a way to parameterize the Gist name
# and remove the literal name from this script that is public on Github
SECRET_GIST_DIR="$(grep password ${MBO_CREDS}|sed 's/\"//g'|awk '{ print $3 }')"
SECRET_GIST_FILE="mobileBookmarkOverflow.html"
SECRET_GIST="git@gist.github.com:${SECRET_GIST_DIR}.git"
# the description and URL are passed as a single quoted string argument
# hopefully special Ascii or UTF/Unicode characters will not give grief
# HMMM , should pass these strings through an escape function
COMMAND_ARGS="${*}"
# have to do this to get the URL in the last token of that string
set -- ${COMMAND_ARGS}
typeset -i ARG_COUNT=${#}
# could not use ${ARG_COUNT} within the outer braces in next statement ,
# else would get error : ${"${ARG_COUNT}"}: bad substitution
# had to use the previously unknown to me Bash indirection feature . 
# from man page , under headings EXPANSION -> Parameter Expansion :
#    If the first character of parameter is an  exclamation  point  (!),  it
#    introduces a level of variable indirection.  Bash uses the value of the
#    variable formed from the rest of parameter as the name of the variable;
#    this  variable  is  then expanded and that value is used in the rest of
#    the substitution, rather than the value of parameter itself.   This  is
#    known as indirect expansion.  
LAST_ARG=${!ARG_COUNT}
cd ${TEMPDIR}
git clone ${SECRET_GIST}
BAD_STATUS=${?}
if [ ${BAD_STATUS} -eq 0 ];then
cd ${SECRET_GIST_DIR}
echo ${COMMAND_ARGS} >> ${SECRET_GIST_FILE}
# ERROR : on tablet , git commit fails msg : "Please tell me who you are"
# FIX : copy ~/.gitconfig from laptop , suffix user.name with device name
# commit message is the URL which should be last cmd line argument
git commit -m "${LAST_ARG}" ${SECRET_GIST_FILE}
BAD_STATUS=${?}
 if [ ${BAD_STATUS} -eq 0 ];then
 git push
 fi
fi
# have to delete the cloned directory , else next clone operation fails
cd ${TEMPDIR}
rm -rf ${SECRET_GIST_DIR}
exit ${BAD_STATUS}
