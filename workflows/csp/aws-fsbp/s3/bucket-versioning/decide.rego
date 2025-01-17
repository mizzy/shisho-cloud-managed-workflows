package policy.aws.s3.bucket_versioning

import data.shisho

decisions[d] {
	account := input.aws.accounts[_]
	bucket := account.s3.buckets[_]

	allowed := versioning_enabled(bucket.versioning)

	d := shisho.decision.aws.s3.bucket_versioning({
		"allowed": allow_if_excluded(allowed, bucket),
		"subject": bucket.metadata.id,
		"payload": shisho.decision.aws.s3.bucket_versioning_payload({"versioning_enabled": allowed}),
	})
}

versioning_enabled(versioning) {
	versioning.status == "ENABLED"
} else = false

allow_if_excluded(allowed, r) {
	data.params != null

	tag := data.params.tag_exceptions[_]
	elements := split(tag, "=")

	tag_key := elements[0]
	tag_value := concat("=", array.slice(elements, 1, count(elements)))

	t := r.tags[_]
	t.key == tag_key
	t.value == tag_value
} else := allowed
