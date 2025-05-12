#!/usr/bin/env bats

############################################################################
# Tests for create_review_report function
############################################################################

# Load the library containing our function
load ../shell/lib/stashie-core-review.sh

setup() {
  # Create a temporary directory for test outputs
  TEST_TEMP_DIR="$(mktemp -d)"

  # Define test arrays
  ALL_FILES=("file1.txt" "file2.txt" "file3.txt" "file4.txt" "")
  REVIEWED_FILES=("file2.txt" "file4.txt" "")

  # Set output path to our temp directory
  OUTPUT_FILE="${TEST_TEMP_DIR}/test-review.md"
}

teardown() {
  # Clean up temporary files after each test
  rm -rf "${TEST_TEMP_DIR}"
}

@test "create_review_report generates correct markdown with files needing review" {
  # Call the function with our test data
  create_review_report ALL_FILES REVIEWED_FILES "${OUTPUT_FILE}"

  # Check that the file was created
  [ -f "${OUTPUT_FILE}" ]

  # Check the content of the file
  run cat "${OUTPUT_FILE}"

  # Verify header is present
  [[ "${output}" == *"### Files Needing Review"* ]]

  # Verify file1.txt is in the report (needs review)
  [[ "${output}" == *"- [ ] [file1.txt](file1.txt)"* ]]

  # Verify file3.txt is in the report (needs review)
  [[ "${output}" == *"- [ ] [file3.txt](file3.txt)"* ]]

  # Verify file2.txt is NOT in the report (already reviewed)
  [[ "${output}" != *"- [ ] [file2.txt](file2.txt)"* ]]

  # Verify file4.txt is NOT in the report (already reviewed)
  [[ "${output}" != *"- [ ] [file4.txt](file4.txt)"* ]]
}

@test "create_review_report handles empty arrays" {
  local EMPTY_ALL=()
  local EMPTY_REVIEWED=()

  # Call with empty arrays
  create_review_report EMPTY_ALL EMPTY_REVIEWED "${OUTPUT_FILE}"

  # Check file exists
  [ -f "${OUTPUT_FILE}" ]

  # Check content - should only have the header
  run cat "${OUTPUT_FILE}"
  [[ "${output}" == "### Files Needing Review" ]]
}

@test "create_review_report uses default output path when none provided" {
  # Mock git command to return a known directory
  git() {
    echo "${TEST_TEMP_DIR}"
  }
  export -f git

  # Call without specifying output path
  create_review_report ALL_FILES REVIEWED_FILES

  # Check that default file was created
  [ -f "${TEST_TEMP_DIR}/stashie-review.md" ]

  # Verify content
  run cat "${TEST_TEMP_DIR}/stashie-review.md"
  [[ "${output}" == *"### Files Needing Review"* ]]
  [[ "${output}" == *"- [ ] [file1.txt](file1.txt)"* ]]
  [[ "${output}" == *"- [ ] [file3.txt](file3.txt)"* ]]
}

@test "create_review_report handles files with spaces in names" {
  local FILES_WITH_SPACES=("file with spaces.txt" "normal_file.txt")
  local REVIEWED_WITH_SPACES=("normal_file.txt")

  # Call the function
  create_review_report FILES_WITH_SPACES REVIEWED_WITH_SPACES "${OUTPUT_FILE}"

  # Check content
  run cat "${OUTPUT_FILE}"
  [[ "${output}" == *"- [ ] [file with spaces.txt](file with spaces.txt)"* ]]
  [[ "${output}" != *"- [ ] [normal_file.txt](normal_file.txt)"* ]]
}

@test "create_review_report returns success status code" {
  # Call the function and check its return code
  run create_review_report ALL_FILES REVIEWED_FILES "${OUTPUT_FILE}"
  [ "$status" -eq 0 ]
  [[ "${output}" == *"Created"* ]]
}
