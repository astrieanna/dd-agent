from nose.plugins.attrib import attr

from checks import AgentCheck
from tests.checks.common import AgentCheckTest

# TODO: convert to test Jenkins
@attr(requires='jenkins')
class TestJenkins(AgentCheckTest):
    CHECK_NAME = 'jenkins'
    CHECK_GAUGES = [
        'jenkins.job.success',
        'jenkins.job.failure',
        'jenkins.job.duration',
    ]

    def __init__(self, *args, **kwargs):
        AgentCheckTest.__init__(self, *args, **kwargs)
        self.config = {
            'instances': [
                {
		    'jenkins_home': '/pay/jenkins0/',
		    'name': 'jenkins1'
                }
            ]
        }

    def test_jenkins(self):
        self.run_check(self.config)
	self.config['instances']['jenkins_home'] = '/pay/jenkins1/'
	self.check(self.config)
        self.coverage_report()

