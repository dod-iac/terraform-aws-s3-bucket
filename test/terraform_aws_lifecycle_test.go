// =================================================================
//
// Work of the U.S. Department of Defense, Defense Digital Service.
// Released as open source under the MIT License.  See LICENSE file.
//
// =================================================================

package test

import (
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

func TestTerraformLifecycleExample(t *testing.T) {

	// Allow test to run in parallel with other tests
	t.Parallel()

	region := os.Getenv("AWS_DEFAULT_REGION")

	// If AWS_DEFAULT_REGION environment variable is not set, then fail the test.
	require.NotEmpty(t, region, "missing environment variable AWS_DEFAULT_REGION")

	// Append a random suffix to the test name, so individual test runs are unique.
	// When the test runs again, it will use the existing terraform state,
	// so it should override the existing infrastructure.
	testName := fmt.Sprintf("terratest-s3-bucket-lifecycle-%s", strings.ToLower(random.UniqueId()))

	tags := map[string]interface{}{
		"Automation": "Terraform",
		"Terratest":  "yes",
		"Test":       "TestTerraformLifecycleExample",
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// TerraformDir is where the terraform state is found.
		TerraformDir: "../examples/lifecycle",
		// Set the variables passed to terraform
		Vars: map[string]interface{}{
			"test_name": testName,
			"tags":      tags,
		},
		// Set the environment variables passed to terraform.
		// AWS_DEFAULT_REGION is the only environment variable strictly required,
		// when using the AWS provider.
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
	})

	// If TT_SKIP_DESTROY is set to "1" then do not destroy the intrastructure,
	// at the end of the test run
	if os.Getenv("TT_SKIP_DESTROY") != "1" {
		defer terraform.Destroy(t, terraformOptions)
	}

	// InitAndApply runs "terraform init" and then "terraform apply"
	terraform.InitAndApply(t, terraformOptions)
}
