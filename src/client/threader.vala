/* threader.vala
 *
 * Copyright 2023 Rirusha
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace CassetteClient {

    public delegate void ThreadFunc (Value[]? func_args);
    //  public delegate void SourceFunc ();

  class ThreadInfo {

        public weak ThreadFunc func;
        public Value[]? func_args;  //  Список чего-либо, в котором хрянится что-либо для сохранения от непредвиденного освобождения

        public ThreadInfo (ThreadFunc func, owned Value[] func_args) {
            this.func = func;
            this.func_args = func_args;
        }

        public void run () {
            func (func_args);
        }
    }

  class WorkManager : Object {

        AsyncQueue<ThreadInfo> thread_datas = new AsyncQueue<ThreadInfo> ();

        Mutex mutex = Mutex ();
        Cond cond = Cond ();

        int running_jobs_count = 0;
        public int max_running_jobs { get; construct; }

        public WorkManager (int max_running_jobs) {
            Object (max_running_jobs: max_running_jobs);
        }

        construct {
            new Thread<void> (null, work);
        }

        void work () {
            while (true) {
                mutex.lock ();

                if (running_jobs_count >= 10) {
                    cond.wait (mutex);
                }

                lock (running_jobs_count) {
                    running_jobs_count++;
                }

                new Thread<void> (null, () => {
                    var worker = thread_datas.pop ();
                    worker.run ();

                    lock (running_jobs_count) {
                        running_jobs_count--;
                    }

                    cond.signal ();
                });

                mutex.unlock ();
            }
        }

        public void add (ThreadFunc func, Value[]? func_args = null) {
            thread_datas.push (new ThreadInfo (func, func_args));
        }
    }

    // Класс менеджер потоков
    public class Threader : Object {

        //  Стандартный пул потоков
        WorkManager default_pool;
        //  Пул потоков для задач кэширования
        WorkManager image_pool;
        //  Пул потоков для важных задач, так как первые два могут быть заполнены
        WorkManager audio_pool;
        //  Пул потоков для задач, выполнение которых не должно пересекаться (размер - 1)
        WorkManager single_pool;

        construct {
            int max_size = storager.settings.get_int("max-thread-number");

            default_pool = new WorkManager (max_size);
            image_pool = new WorkManager (max_size);
            audio_pool = new WorkManager (max_size);
            single_pool = new WorkManager (1);
        }

        public void add (ThreadFunc func, Value[]? func_args = null) {
            default_pool.add (func, func_args);
        }

        public void add_image (ThreadFunc func, Value[]? func_args = null) {
            image_pool.add (func, func_args);
        }

        public void add_audio (ThreadFunc func, Value[]? func_args = null) {
            audio_pool.add (func, func_args);
        }

        public void add_single (ThreadFunc func, Value[]? func_args = null) {
            single_pool.add (func, func_args);
        }
    }
}