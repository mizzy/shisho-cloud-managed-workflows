package policy.googlecloud.iam.service_account_project_impersonation_role

import data.shisho
import future.keywords

test_whether_service_accont_impersonation_is_prevented_for_projects if {
	# check if the the service account impersonation is prevented properly for projects
	count([d |
		decisions[d]
		shisho.decision.is_allowed(d)
	]) == 4 with input as {"googleCloud": {"projects": [
		{
			"id": "test-project-1",
			"metadata": {"id": "googlecloud-project|5148937777"},
			"iamPolicy": {"bindings": [
				{
					"members": [{"id": "serviceAccount:5148937777@cloudbuild.gserviceaccount.com"}],
					"role": "roles/stackdriver.accounts.viewer",
				},
				{
					"members": [{"id": "serviceAccount:service-5148937777@gcp-sa-cloudbuild.iam.gserviceaccount.com"}],
					"role": "roles/viewer",
				},
			]},
		},
		{
			"id": "test-project-2",
			"metadata": {"id": "googlecloud-project|5148938888"},
			"iamPolicy": {"bindings": [
				{
					"members": [{"id": "serviceAccount:5148938888@test-project-2.iam.gserviceaccount.com"}],
					"role": "projects/test-project-2/roles/containerizer_node_role",
				},
				{
					"members": [{"id": "serviceAccount:service-5148938888@test-project-2.iam.gserviceaccount.com"}],
					"role": "roles/cloudsql.client",
				},
			]},
		},
		{
			"id": "test-project-3",
			"metadata": {"id": "googlecloud-project|5148939999"},
			"iamPolicy": {"bindings": []},
		},
		{
			"id": "test-project-4",
			"metadata": {"id": "googlecloud-project|5148936666"},
			"iamPolicy": {"bindings": [{
				"members": [],
				"role": "projects/test-project-2/roles/containerizer_node_role",
			}]},
		},
	]}}

	# check if the the service account impersonation is prevented properly for projects
	count([d |
		decisions[d]
		not shisho.decision.is_allowed(d)
	]) == 2 with input as {"googleCloud": {"projects": [
		{
			"id": "test-project-1",
			"metadata": {"id": "googlecloud-project|5148937777"},
			"iamPolicy": {"bindings": [
				{
					"members": [{"id": "serviceAccount:5148937777@cloudbuild.gserviceaccount.com"}],
					"role": "roles/iam.serviceAccountUser",
				},
				{
					"members": [{"id": "serviceAccount:service-5148937777@gcp-sa-cloudbuild.iam.gserviceaccount.com"}],
					"role": "roles/iam.serviceAccountTokenCreator",
				},
			]},
		},
		{
			"id": "test-project-2",
			"metadata": {"id": "googlecloud-project|5148938888"},
			"iamPolicy": {"bindings": [
				{
					"members": [{"id": "serviceAccount:5148938888@fslp-dev.iam.gserviceaccount.com"}],
					"role": "roles/iam.serviceAccountUser",
				},
				{
					"members": [{"id": "serviceAccount:service-5148938888@fslp-dev.iam.gserviceaccount.com"}],
					"role": "roles/iam.serviceAccountTokenCreator",
				},
			]},
		},
	]}}
}
