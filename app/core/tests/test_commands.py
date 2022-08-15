"""
Test custom Django management commands.
"""
from unittest.mock import patch

from psycopg2 import OperationalError as Psycopg2OpError

from django.core.management import call_command
from django.db.utils import OperationalError
from django.test import SimpleTestCase


@patch("core.management.commands.wait_for_db.Command.check")
class CommandTest(SimpleTestCase):
    """Test commands."""

    def test_wait_for_db_ready(self, patched_check):
        """Test waiting for database if database is ready."""

        # Mocking the database is ready to be accessed and returns the value True
        patched_check.return_value = True

        call_command('wait_for_db')

        # Have to assert_called_once_with here since we are accessing the database only once
        patched_check.assert_called_once_with(databases=['default'])

    # Overrides the sleep method used in the command so the test doesn't wait for sleep to occur
    @patch('time.sleep')
    # Order is important, patch args are applied from the inside out, so patched_sleep is first, patched_check is second
    def test_wait_for_db_delay(self, patched_sleep, patched_check):
        """Test waiting for database when getting OperationalError."""

        # Mocking an exception being raised, the first two times raise Psycopg2Error, the next three times raise
        # OperationalError ( postgres can give differing errors depending on what stage of the startup process )
        # the final sixth time it will return True
        patched_check.side_effect = [Psycopg2OpError] * 2 + [OperationalError] * 3 + [True]

        call_command('wait_for_db')

        # Check that the command was called 2 (Psycopg2 Error) + 3 (Operational Error) + 1 (True) times
        self.assertEqual(patched_check.call_count, 6)

        # Have to use assert_called_with here since we are accessing the database multiple times
        patched_check.assert_called_with(databases=['default'])
