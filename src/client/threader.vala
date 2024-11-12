/* Copyright 2023-2024 Vladimir Vaskov
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
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Cassette.Client {

    public delegate void ThreadFunc ();

    class ThreadInfo {

        public weak ThreadFunc func;
        public Cancellable? cancellable;

        public ThreadInfo (ThreadFunc func, Cancellable? cancellable) {
            this.func = func;
            this.cancellable = cancellable;
        }

        public void run () {
            if (cancellable != null) {
                if (cancellable.is_cancelled ()) {
                    return;
                }
            }

            func ();
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

                if (running_jobs_count >= max_running_jobs) {
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

        public void add (ThreadFunc func, Cancellable? cancellable) {
            thread_datas.push (new ThreadInfo (func, cancellable));
        }
    }

    // Класс менеджер потоков
    public class Threader : Object {

        //  Стандартный пул потоков
        WorkManager default_pool;
        //  Пул потоков для задач кэширования изображений
        WorkManager image_pool;
        //  Пул потоков для аудио
        WorkManager audio_pool;
        //  Пул потоков для класса Job
        WorkManager cache_pool;
        //  Пул потоков для задач, выполнение которых не должно пересекаться (размер - 1)
        WorkManager single_pool;

        construct {
            int max_size = settings.get_int ("max-thread-number");

            default_pool = new WorkManager (max_size);
            image_pool = new WorkManager (max_size);
            audio_pool = new WorkManager (max_size);
            cache_pool = new WorkManager (max_size / 2);
            single_pool = new WorkManager (1);
        }

        public void add (
            ThreadFunc func,
            Cancellable? cancellable = null
        ) {
            default_pool.add (func, cancellable);
        }

        public void add_image (
            ThreadFunc func,
            Cancellable? cancellable = null
        ) {
            image_pool.add (func, cancellable);
        }

        public void add_audio (
            ThreadFunc func,
            Cancellable? cancellable = null
        ) {
            audio_pool.add (func, cancellable);
        }

        public void add_cache (
            ThreadFunc func,
            Cancellable? cancellable = null
        ) {
            cache_pool.add (func, cancellable);
        }

        public void add_single (
            ThreadFunc func,
            Cancellable? cancellable = null
        ) {
            single_pool.add (func, cancellable);
        }
    }
}
