package policy.aws.secretsmanager.secret_usage

import data.shisho

# secrets must be accessed within `accepted_duration_for_unused_secrets`
# the default is 90 days. Please adjust to your needs.
accepted_duration_for_unused_secrets := 90

decisions[d] {
	account := input.aws.accounts[_]
	secret := account.secretsManager.secrets[_]

	aat := max([
		timestamp_ns(secret.createdAt),
		timestamp_ns(secret.lastAccessedAt),
	])

	allowed := accessed_within_specified_days(aat, accepted_duration_for_unused_secrets)

	d := shisho.decision.aws.secretsmanager.secret_usage({
		"allowed": allow_if_excluded(allowed, secret),
		"subject": secret.metadata.id,
		"payload": shisho.decision.aws.secretsmanager.secret_usage_payload({"last_accessed_at": last_accessed_at(secret.lastAccessedAt)}),
	})
}

last_accessed_at(last_accessed_at) = last_accessed_at {
	last_accessed_at != null
} else := ""

accessed_within_specified_days(ts, d) {
	now := time.now_ns()

	diff_ns := now - ts

	# True if the difference is less than `d` days
	diff_ns < (((1000000000 * 60) * 60) * 24) * d
} else = false

timestamp_ns(t) := 0 {
	t == null
} else := time.parse_rfc3339_ns(t)

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
