#!/bin/bash

##############  About me  ################


# Made by: Valentin Todorov
# Email: valentin.v.todorov@gmail.com


######  What is the script doing  ########


# This Bash script initiates a sequence to process a specific file named "bigf.json.bz2." 
#
# Initially, it checks if the file exists within the user's Downloads directory.
#
# If found, it prompts the user to confirm whether the file has been extracted. 
# If extracted, the script requests the path and file name of the extracted file.
#
# Otherwise, it guides the user to specify an extraction location and conducts the extraction process using " bunzip2 ".
#
# Following the extraction, the script sorts the content of the extracted file into rows for easier 
# and most importantly lighter manipulation, saves it to a file named "json_in_rows.txt," and subsequently 
# processes this information to obtain specific data. 
#
# It extracts information related to a 'model' field, sorts the model names, counts each unique model, and outputs 
# this information in a formatted table in a file named "final_result.txt". 
#
# The entire process concludes after displaying the final table of model counts. 
#
# The script will take approximately 10-20 minutes to execute and after the process is completed, the script exits.



##############  Variables  ###############


##### Global
# File name
file_name="bigf.json.bz2"

##### Main
# Search for the file in the Downloads directory and save its path to a variable.
# Based on the outcome the script will load different function
file_path=$(find /home/$USER/Downloads -type f -name "$file_name" 2>/dev/null)

##### extraction
# Name of the extracted file if the script is extracting it
extracted_file="bigf.json"



##############  Functions  ###############


# This function manages the extraction process, asking the user whether the file 
# has been extracted or not and prompting for necessary details.

extraction(){
    while true; do
        echo ""
        read -p "Have you extracted the file $file_name ? (yes/no): " extracted

        if [ "$extracted" = "yes" ]; then
            # User has extracted the file
            while true; do
                # Ask for the path, file name and extension of the extracted file
                read -p "Please provide the full path where the file was extracted: " path
                read -p "Please provide the exact file name and extension of the extracted file: " user_extracted_file
                # PATH TO THE USER'S EXTRACTED FILE >> $path <<
                # NAME OF THE USER'S EXTRACTED FILE >> $user_extracted_file <<

                # Check if the provided file path and name exist
                #  -f  = If the file exists, the code within the if block will be executed.
                if [ -f "$path/$user_extracted_file" ]; then
                    echo "$user_extracted_file found at $path"   
                    path_to_extracted_file=$path/$user_extracted_file
                    break
                else
                    echo "The file $user_extracted_file is not in the provided path. Please try again."
                    echo ""
                fi
            done
            break

        elif [ "$extracted" = "no" ]; then
            # User hasn't extracted the file
            while true; do
                echo ""
                echo "NOTE: The extracted file will be about 21GiB"
                read -p "Where do you want the file to be extracted? (Please provide the full path): " extraction_path

                # Check if the extraction path provided exists
                #  -d  = If the path corresponds to a directory, the code within the if block will be executed.
                if [ -d "$extraction_path" ]; then
                    echo "Starting extraction at $extraction_path..."
                    # bunzip2 is used to decompress files compressed with the bzip2 
                    #  -k  = It preserves the input file and creates the output separately
                    #  -c  = specifies that the output will be directed to (stdout) 
                    #        rather than overwriting the input file 
                    bunzip2 -k "$file_path" -c > "$extraction_path/$extracted_file"
                    path_to_extracted_file=$extraction_path/$extracted_file
                    echo "Extraction completed."
                    break
                else
                    echo "The provided path does not exist. Please provide a valid path."
                fi
            done
            break

        else
            echo "Please enter either 'yes' or 'no'."
        fi
    done
}


file_located_in_downloads(){
    echo "File found at: $file_path"
    extraction
    json_in_rows
    final_result
}

file_NOT_located_in_downloads() {
    file_found=false

    # This loop continues until the file is found in the user-provided path.
    while [ "$file_found" != true ]; do
        echo ""
        echo "Download the bigf.json.bz2 file or..."
        read -p "Enter the path for the bigf.json.bz2 file: " user_path

        # Check if the file exists in the provided path.
        #  -e  = Check if a directory (or in our case a file) exists.
        if [ -e "$user_path/$file_name" ]; then
            echo "File $file_name found in path: $user_path"
            # Update file_path here with the found file's path
            file_path="$user_path/$file_name"
            extraction
            json_in_rows
            final_result
            # Set the value of file_found variable to true if the file 
            # is found at the provided path in order to stop the loop
            file_found=true  
        else
            echo ""
            echo "The file $file_name was not found in the provided path. Please try again."
        fi
    done
}

json_in_rows(){
    echo ""
    echo "Sorting the file information into rows for lighter text manipulation later."
    echo "This will take about a minute."
    # Creating a variable for the file where the sorted information will be stored.
    json_in_rows="json_in_rows.txt"
    # The command >>  tr ',' '\n'  << will replace every comma with a newline 
    # breaking the line into individual lines. Then the >>  paste -d',' - - -  << command 
    # takes these individual lines and groups them into lines containing three elements separated by commas. 
    tr ',' '\n' < "${path_to_extracted_file}" | paste -d',' - - - >> "${json_in_rows}"
    echo ""
    echo "Sorting done."
    echo ""
}

final_result(){
    echo "Starting the final information extraction."
    echo ""
    echo "Those are the last few minutes of waiting."
    echo "Please stand by. :)"
    echo ""
    # Set the variable for the final result file name
    final_result="final_result.txt"
    # Explanation 1
    awk -F'"model":"' '{print $2}' "${json_in_rows}" | awk -F'"' '{print $1}' | sort | uniq -c >> "${final_result}"
    echo "All done!"
    echo ""
    echo "Count     Model"
    echo "------------------"
    # Explanation 2
    awk '{printf "%-6s %s\n", $1, $2}' "${final_result}" | column -t
    exit 1
}
    #### Explanation 1
    #
    # Using AWK to process the 'json_in_rows' file content:
    # 1. -F'"model":"' sets the field separator as '"model":'
    # 2. '{print $2}' prints the content after the '"model":' field
    # 3. The second AWK command: -F'"' sets the field separator as double quotes
    # 4. '{print $1}' prints the content before the first double quote
    # 5. | sort sorts the model names
    # 6. | uniq -c counts each unique model
    # 7. >> "${final_result}" appends the output to the final result file

    #### Explanation 2
    #
    # Using AWK to format the final result for display:
    # 1. {printf "%-6s %s\n", $1, $2} formats the first column to take up 6 spaces and adds the second column, followed by a newline
    # 2. "${final_result}" references the final result file created earlier
    # 3. | column -t formats the output into aligned columns for better readability

#################  Main  ##################


echo "Hello there! :)"
echo ""
echo "The following process will take about 10 - 15 minutes."
echo ""
echo "When the script is done, you will be able to review the files that "
echo "this script has created in the same directory where the script is located."
echo ""

# Check if the variable 'file_path' is NOT empty
if [ -n "$file_path" ]; then
    file_located_in_downloads
else
    echo "The file bigf.json.bz2 was not found in your Download directory."
    file_NOT_located_in_downloads
fi


###########################################


# Thank you! :)

