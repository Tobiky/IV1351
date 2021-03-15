import psycopg2
from datetime import datetime
from copy import deepcopy

class DB(object):
    def __init__(self) -> None:
        super().__init__()

    def connect(self):
        self.__enter__()

    def disconnect(self):
        self.__exit__(None, None, None)

    def __enter__(self):
        self.db_connection = psycopg2.connect(
            host='localhost',
            port='5432',
            database='soundgood_db',
            user='postgres',
            password='example')
        self.db_connection.autocommit = False
        self.cursor = self.db_connection.cursor()
        return self

    def __exit__(self, type, value, tb):
        self.cursor.close()
        self.db_connection.close()
        return self

    def _instrument_id(self, instrument_name: str):
        self.cursor.execute(
            'SELECT * FROM instrument WHERE instrument_name = %s;',
            [instrument_name])
        self.db_connection.commit()
        try:
            (id, _) = self.cursor.fetchone()
            return id
        except:
            return -1

    def list(self, instrument_name: str):
        instrument_id = self._instrument_id(instrument_name)
        self.cursor.execute(
            'SELECT * FROM instrument_product WHERE instrument_id = %s AND stock_quantity > 0;',
            [instrument_id])
        self.db_connection.commit()
        try:
            return self.cursor.fetchall()
        except:
            return list()

    # Program just quits after calling this
    def rent(self, product_id: int, student_id: int):
        try:
            self.cursor.execute(
                'SELECT time_slot_id FROM instrument_rental WHERE student_id = %s;',
                [student_id])
            rental_time_slot_ids = self.cursor.fetchall()
        except Exception:
            self.db_connection.rollback()
            return False

        rentals = 0
        for time_slot in rental_time_slot_ids:
            try:
                self.cursor.execute(
                    'SELECT * FROM time_slot WHERE id = %s AND ending_date_time > NOW();',
                    time_slot)
                if self.cursor.fetchone() is not None:
                    rentals += 1
            except Exception:
                self.db_connection.rollback()
                return False

        if rentals > 2:
            return False

        try:
            self.cursor.execute(
                'INSERT INTO time_slot (start_date_time, ending_date_time) VALUES (NOW(), NOW() + INTERVAL %s) RETURNING id;',
                ['6 month'])
            new_time_slot_id = self.cursor.fetchone()
        except Exception:
            self.db_connection.rollback()
            return False

        try:
            self.cursor.execute(
                'UPDATE instrument_product SET stock_quantity = stock_quantity - 1 WHERE stock_quantity > 0 AND id = %s RETURNING cost, instrument_id;',
                [product_id])
            (cost, instrument_id) = self.cursor.fetchone()
        except Exception:
            self.db_connection.rollback()
            return False

        try:
            self.cursor.execute(
                'INSERT INTO instrument_rental (instrument_product_id, instrument_id, time_slot_id, student_id, rental_charge) VALUES (%s, %s, %s, %s, %s) RETURNING *;',
                [product_id, instrument_id, new_time_slot_id, student_id, cost])
            result = self.cursor.fetchone()
        except Exception as e:
            print(e)
            self.db_connection.rollback()
            return False

        if result is None:
            self.db_connection.rollback()
            return False
        else:
            self.db_connection.commit()
            return True

    def terminate(self, product_id: int, student_id: int):
        try:
            self.cursor.execute(
                'SELECT time_slot_id FROM instrument_rental WHERE student_id = %s AND instrument_product_id = %s;',
                [student_id, product_id])
            time_slot_id = self.cursor.fetchone()
        except:
            self.db_connection.rollback()
            return False

        if time_slot_id is None:
            self.db_connection.rollback()
            return False

        try:
            # fetchone will never return None here as above confirmes the existence of the time slot
            self.cursor.execute(
                'UPDATE time_slot SET ending_date_time = NOW() WHERE id = %s RETURNING *;',
                [time_slot_id])
            _ = self.cursor.fetchone()
        except:
            self.db_connection.rollback()
            return False

        try:
            self.cursor.execute(
                'UPDATE instrument_product SET stock_quantity = stock_quantity + 1 WHERE id = %s RETURNING *;',
                [product_id])
            result = self.cursor.fetchone()
        except:
            self.db_connection.rollback()
            return False

        if result is None:
            self.db_connection.rollback()
            return False

        self.db_connection.commit()
        return True
