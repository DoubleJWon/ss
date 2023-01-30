#!/bin/bash

gate_output_path='/home/jaewonjeong/shell_script/ss/ss'
input_format='DC_SR15H30_CH15S1_SP'

: << END

END


echo "### Start shell script."



#########################Debug mode ###############################################

if [ -z $1 ]; then
	condor_q="condor_q" 
else
	condor_q=$1
fi

if [ -z $2 ]; then
	condor_q2="condor_q2"
else
	condor_q2=$2
fi

if [ -z $3 ]; then
	check_time=60m
else
	check_time="$3m"
fi


if [ -z $4 ]; then
	check_time=120m
else
	check_dead_time="$4m"
fi

printf "## condor_q : $condor_q \n"
printf "## condor_q2 : $condor_q2 \n"
printf "## check_time : ${check_time} \n"
printf "## check_dead_time : ${check_dead_time} \n"


if [ $5 == 'd' ]; then
	gate_output_path='/home/jaewonjeong/shell_script/ss/ss'
	input_format='DC_SR15H30_CH15S1_SP'
else
	gate_output_path='/home/boram/.Gate/'
	input_format='DC_SR15H30_CH15S1_SP'
fi

current_working_path="none"
printf "## gate_output_path : ${gate_output_path} \n"
printf "## input_format : ${input_format} \n"
printf "## current_working_path (init): ${current_working_path} \n"
###################################################################################
#echo "${gate_output_path}"
#echo "${input_format}"
#ls -al ${gate_output_path}

#fdfind -p "${gaet_output_path}" -t d -g "${input_format}"

#fdfind $input_format -t d -p ${gate_output_path}

#echo ""
#fdfind $input_format -t d -p ${gate_output_path} 

#echo "current_working_path : "
#fdfind $input_format -t d -p ${gate_output_path} | xargs echo | awk '{print $NF}'

printf "### current_working_path : "
current_path='fdfind $input_format -t d -p ${gate_output_path} | xargs echo | awk ''{print $NF}'''
current_working_path=`fdfind $input_format -t d -p ${gate_output_path} | xargs echo | awk '{print $NF}'`

#current_working_path='/home/jaewonjeong/shell_script/ss/ss'
echo $current_working_path

printf "\n\n"

## the last mrdir of GATE Simul.
#fdfind $input_format -t d -p ${gate_output_path} | xargs echo | awk '{print $NF}'

#running_jobs=`condor_q | cat |tail -2 | awk '{print $13}'`
running_jobs=` cat $condor_q | cat |tail -2 | awk '{print $13}'`


printf "### running jobs : ${running_jobs} \n"

id_user=`cat $condor_q | awk '{print $1}' | xargs echo | awk '{print $3}'| cut -d "." -f 1`
printf "### ID User : ${id_user} \n"


printf "### ID Cluster : ${id_cluster} \n"
#printf "### start index : ${start_index} \n"
#printf "### end index : ${end_index} \n"
id_cluster=`cat $condor_q2 | awk '{print $1}' | xargs echo | awk '{print $3}' | cut -d " " -f 3 | cut -d "." -f 1`


let start_index=3
let end_index=start_index+running_jobs-1


if [ ${running_jobs} -eq 0 ]; then
	echo "### good! Complete all jobs of condor."
	echo "sudo service cron stop " 
else
	echo "### running!!"
	#	fdfind --change-older-than 200m -e out p ${current_working_path} 
	printf "### Be incompleted IDs of Jobs\n\n"
	for ((i=$start_index; i <= $end_index; i++))
	do
	echo "######################################################"
		#condor_q -nobatch | awk '{print $1}' | xargs echo | awk '{print $$i}'| cut -d "." -f 2
		#printf "i = ${i} \n"
		id_job=`cat $condor_q2 | awk '{print $1}' | xargs echo | awk -v "num=$i" '{print $num}' | cut -d " " -f 3 | cut -d "." -f 2`
		let id_file=$id_job+1
		let numth=$i-$start_index  
		printf "### Id job(${numth}th) : ${id_job}\n"

		 
		is_file=`fdfind "DC_SR15H30_CH15S1_SP${id_file}.out" --change-older-than ${check_time} -e out -p "${current_working_path}"`
		is_dead_job=`fdfind "DC_SR15H30_CH15S1_SP${id_file}.out" --change-older-than ${check_dead_time} -e out -p "${current_working_path}"` 

		
		if [ -z $is_file ]; then
			echo "null : is_file"
		else 
			echo "is_file : $is_file"
		fi

		if [ -z $is_dead_job ]; then
			echo "is_dead_job : null"
		else
			echo "is_dead_job : $is_dead_job"
		fi

		if [ ! -z ${is_file} ]; then ### hold and release
			if  [ ! -z ${is_dead_job} ]; then
				echo "condor_hold ${id_cluster}.${id_job}"
				echo "condor_rm ${id_cluster}.${id_job}"
			else
				#condor_hold "${id_cluster}.${id_job}"
				#condor_release "${id_cluster}.${id_job}"
				echo "condor_hold ${id_cluster}.${id_job}"
				echo "condor_release ${id_cluster}.${id_job}"
			fi
		
		fi
		echo ""
	done
	

fi







#fdfind --change-older-than 200m -e out p ${current_working_path}
